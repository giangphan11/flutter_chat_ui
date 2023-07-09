import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:flyer_chat_text_message/flyer_chat_text_message.dart';
import 'package:provider/provider.dart';
import './chat_animated_list.dart';

class Chat extends StatefulWidget {
  final List<Message> messages;
  final String userId;
  final ChatTheme? theme;
  final MediaCache? mediaCache;
  final Storage? storage;

  const Chat({
    super.key,
    required this.messages,
    required this.userId,
    this.theme,
    this.mediaCache,
    this.storage,
  });

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with WidgetsBindingObserver {
  late ChatTheme _theme;
  late MediaCache _mediaCache;
  late Storage _storage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateTheme();
    _mediaCache = widget.mediaCache ?? MediaCache();
    _storage = widget.storage ?? InMemoryStorage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(_updateTheme);
  }

  @override
  void didUpdateWidget(covariant Chat oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.theme != widget.theme) {
      _theme = _theme.merge(widget.theme);
    }
  }

  void _updateTheme() {
    _theme =
        ChatTheme.defaultTheme(PlatformDispatcher.instance.platformBrightness)
            .merge(widget.theme);
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider.value(value: widget.userId),
          Provider.value(value: _theme),
          Provider.value(value: _mediaCache),
          Provider.value(value: _storage),
        ],
        child: ChatWidget(
          messages: widget.messages,
        ),
      );
}

class ChatWidget extends StatelessWidget {
  final List<Message> messages;

  const ChatWidget({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        context.select((ChatTheme theme) => theme.backgroundColor);
    final userId = context.watch<String>();

    return Container(
      color: backgroundColor,
      child: ChatAnimatedList(
        items: messages,
        itemBuilder: (_, item) => Align(
          alignment: item.senderId == userId
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: item is TextMessage
              ? FlyerChatTextMessage(
                  key: ValueKey(item.id),
                  message: item,
                )
              : FlyerChatImageMessage(
                  key: ValueKey(item.id),
                  message: item as ImageMessage,
                ),
        ),
        insertAnimationBuilder: (context, animation, item, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.linearToEaseOut,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SizeTransition(
              sizeFactor: curvedAnimation,
              child: ScaleTransition(
                scale: curvedAnimation,
                alignment: item.senderId == userId
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: child,
              ),
            ),
          );
        },
        removeAnimationBuilder: (context, animation, item, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SizeTransition(
              sizeFactor: curvedAnimation,
              child: ScaleTransition(
                scale: curvedAnimation,
                alignment: item.senderId == userId
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
