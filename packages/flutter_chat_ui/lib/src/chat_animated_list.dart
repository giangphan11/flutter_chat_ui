import 'package:diffutil_dart/diffutil.dart' as diffutil;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:provider/provider.dart';

class ChatAnimatedList extends StatefulWidget {
  const ChatAnimatedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.insertAnimationBuilder,
    required this.removeAnimationBuilder,
    this.insertAnimationDuration = const Duration(milliseconds: 250),
    this.removeAnimationDuration = const Duration(milliseconds: 250),
    this.scrollToEndAnimationDuration = const Duration(milliseconds: 250),
  });

  final List<Message> items;
  final Widget Function(BuildContext, Message) itemBuilder;
  final Widget Function(
    BuildContext,
    Animation<double>,
    Message,
    Widget,
  ) insertAnimationBuilder;
  final Widget Function(
    BuildContext,
    Animation<double>,
    Message,
    Widget,
  ) removeAnimationBuilder;
  final Duration insertAnimationDuration;
  final Duration removeAnimationDuration;
  final Duration scrollToEndAnimationDuration;

  @override
  ChatAnimatedListState createState() => ChatAnimatedListState();
}

class ChatAnimatedListState extends State<ChatAnimatedList> {
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey();
  late List<Message> _oldList;
  final _scrollController = ScrollController();
  bool _userHasScrolled = false;
  String _lastInsertedMessageId = '';

  @override
  void initState() {
    super.initState();
    _oldList = List.from(widget.items);
  }

  @override
  void didUpdateWidget(ChatAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newList = widget.items;

    final updates = diffutil
        .calculateDiff<Message>(
          MessageListDiff(_oldList, newList),
        )
        .getUpdatesWithData();
    // temp copy of old list to start the animations on the right positions
    final tempList = List<Message?>.from(_oldList);
    for (final update in updates) {
      _onDiffUpdate(update, tempList);
    }
    _oldList = List.from(newList);
  }

  void _initialScrollToEnd() async {
    // Delay the scroll to the end animation so new message is painted, otherwise
    // maxScrollExtent is not yet updated and the animation might not work.
    await Future.delayed(widget.insertAnimationDuration);

    if (!_scrollController.hasClients || !mounted) return;

    if (_scrollController.offset < _scrollController.position.maxScrollExtent) {
      if (widget.scrollToEndAnimationDuration == Duration.zero) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: widget.scrollToEndAnimationDuration,
          curve: Curves.linearToEaseOut,
        );
      }
    }
  }

  void _subsequentScrollToEnd(Message data) async {
    final userId = Provider.of<String>(context, listen: false);

    // In this case we only want to scroll to the bottom if user has not scrolled up
    // or if the message is sent by the current user.
    if (data.id == _lastInsertedMessageId &&
        _scrollController.offset < _scrollController.position.maxScrollExtent &&
        (userId == data.senderId || !_userHasScrolled)) {
      if (widget.scrollToEndAnimationDuration == Duration.zero) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: widget.scrollToEndAnimationDuration,
          curve: Curves.linearToEaseOut,
        );
      }

      if (!_scrollController.hasClients || !mounted) return;

      // Because of the issue I have opened here https://github.com/flutter/flutter/issues/129768
      // we need an additional jump to the end. Sometimes Flutter
      // will not scroll to the very end. Sometimes it will not scroll to the
      // very end even with this, so this is something that needs to be
      // addressed by the Flutter team.
      //
      // Additionally here we have a check for the message id, because
      // if new message arrives in the meantime it will trigger another
      // scroll to the end animation, making this logic redundant.
      if (data.id == _lastInsertedMessageId &&
          _scrollController.offset <
              _scrollController.position.maxScrollExtent &&
          (userId == data.senderId || !_userHasScrolled)) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void _scrollToEnd(Message data) {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        if (!_scrollController.hasClients || !mounted) return;

        // We need this condition because if scroll view is not yet scrollable,
        // we want to wait for the insert animation to finish before scrolling to the end.
        if (_scrollController.position.maxScrollExtent == 0) {
          // Scroll view is not yet scrollable, scroll to the end if
          // new message makes it scrollable.
          _initialScrollToEnd();
        } else {
          _subsequentScrollToEnd(data);
        }
      },
    );
  }

  void _onInserted(
    final int position,
    final Message data,
    final List<Message?> tempList,
  ) {
    final userId = Provider.of<String>(context, listen: false);

    // There is a scroll notification listener the controls the `_userHasScrolled` variable.
    // However, when a new message is sent by the current user we want to
    // set `_userHasScrolled` to false so that the scroll animation is triggered.
    //
    // Also, if for some reason `_userHasScrolled` is true and the user is not at the bottom of the list,
    // set `_userHasScrolled` to false so that the scroll animation is triggered.
    if (userId == data.senderId ||
        (_userHasScrolled == true &&
            _scrollController.offset >=
                _scrollController.position.maxScrollExtent)) {
      _userHasScrolled = false;
    }

    _listKey.currentState!.insertItem(
      position,
      // We are only animating items when scroll view is not yet scrollable,
      // otherwise we just insert the item without animation.
      // (animation is replaced with scroll to bottom animation)
      duration: _scrollController.position.maxScrollExtent == 0
          ? widget.insertAnimationDuration
          : Duration.zero,
    );
    tempList.insert(position, data);

    // Used later to trigger scroll to end only for the last inserted message.
    _lastInsertedMessageId = data.id;

    _scrollToEnd(data);
  }

  void _onRemoved(
    final int position,
    final Message data,
    final List<Message?> tempList,
  ) {
    final oldItem = tempList[position]!;
    _listKey.currentState!.removeItem(
      position,
      (context, animation) => widget.removeAnimationBuilder(
        context,
        animation,
        oldItem,
        widget.itemBuilder(context, oldItem),
      ),
      duration: widget.removeAnimationDuration,
    );
    tempList.removeAt(position);
  }

  void _onChanged(int position) {
    _listKey.currentState!.removeItem(
      position,
      (context, animation) => const SizedBox.shrink(),
      duration: Duration.zero,
    );
    _listKey.currentState!.insertItem(
      position,
      duration: Duration.zero,
    );
  }

  void _onDiffUpdate(
    diffutil.DataDiffUpdate<Message> update,
    List<Message?> tempList,
  ) {
    update.when<void>(
      insert: (pos, data) => _onInserted(pos, data, tempList),
      remove: (pos, data) => _onRemoved(pos, data, tempList),
      change: (pos, oldData, newData) => _onChanged(pos),
      move: (_, __, ___) => throw UnimplementedError('unused'),
    );
  }

  @override
  Widget build(BuildContext context) => Provider(
        create: (_) => _scrollToEnd,
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            // When user scrolls up, save it to `_userHasScrolled`
            if (notification.direction == ScrollDirection.forward) {
              _userHasScrolled = true;
            } else {
              // When user overscolls to the bottom or stays idle at the bottom, set `_userHasScrolled` to false
              if (notification.metrics.pixels ==
                  notification.metrics.maxScrollExtent) {
                _userHasScrolled = false;
              }
            }

            return false;
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAnimatedList(
                key: _listKey,
                initialItemCount: widget.items.length,
                itemBuilder: (
                  BuildContext context,
                  int index,
                  Animation<double> animation,
                ) =>
                    widget.insertAnimationBuilder(
                  context,
                  animation,
                  widget.items[index],
                  widget.itemBuilder(
                    context,
                    widget.items[index],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class MessageListDiff extends diffutil.ListDiffDelegate<Message> {
  MessageListDiff(super.oldList, super.newList);

  @override
  bool areContentsTheSame(int oldItemPosition, int newItemPosition) =>
      equalityChecker(oldList[oldItemPosition], newList[newItemPosition]);

  @override
  bool areItemsTheSame(int oldItemPosition, int newItemPosition) =>
      oldList[oldItemPosition].id == newList[newItemPosition].id;
}
