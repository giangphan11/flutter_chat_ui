import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:thumbhash/thumbhash.dart' hide Image;

import 'mime_to_extension.dart';

class FlyerChatImageMessage extends StatefulWidget {
  final ImageMessage message;

  const FlyerChatImageMessage({
    super.key,
    required this.message,
  });

  @override
  FlyerChatImageMessageState createState() => FlyerChatImageMessageState();
}

class FlyerChatImageMessageState extends State<FlyerChatImageMessage> {
  // late final ImageStream _imageStream;
  // ImageInfo? _imageInfo;
  late double _aspectRatio;
  Uint8List? _bmp;

  @override
  void initState() {
    super.initState();
    final mediaCache = Provider.of<MediaCache>(context, listen: false);

    final bytes = base64Decode(base64.normalize(widget.message.thumbhash!));
    _aspectRatio = thumbHashToApproximateAspectRatio(bytes);
    final fileNameBytes = utf8.encode(widget.message.source);
    final fileName = sha256.convert(fileNameBytes).toString();

    mediaCache.get(fileName).then((value) {
      if (value != null) {
        setState(() {
          _bmp = value['thumbhash']!;
        });
      } else {
        final rgbaImage = thumbHashToRGBA(bytes);
        final newBmp = rgbaToBmp(rgbaImage);
        setState(() {
          _bmp = newBmp;
        });
        mediaCache.set(fileName, {
          'thumbhash': newBmp,
        });
      }
    });

    // _downloadImage();
    // final imageProvider = NetworkImage(widget.message.source);
    // _imageStream = imageProvider.resolve(ImageConfiguration.empty);
    // _imageStream.addListener(
    //   ImageStreamListener(_updateImage, onError: _catchError),
    // );
  }

  // ignore: unused_element
  void _downloadImage() async {
    try {
      final response = await http.get(Uri.parse(widget.message.source));
      final contentType = response.headers['content-type'];
      final responseBytes = response.bodyBytes;
      final mimeType = contentType ??
          lookupMimeType(
            widget.message.source,
            headerBytes: responseBytes.take(16).toList(),
          );
      final extension = mimeToExtension[mimeType] ?? '';
      final fileNameBytes = utf8.encode(widget.message.source);
      final fileName = sha256.convert(fileNameBytes).toString();
      final name = '$fileName$extension';
      final cache = await getApplicationCacheDirectory();
      final file = XFile.fromData(
        response.bodyBytes,
        mimeType: mimeType,
        name: name,
        length: responseBytes.lengthInBytes,
      );
      await file.saveTo('${cache.path}/$name');
    } catch (e) {
      // Handle error
    }
  }

  // void _updateImage(ImageInfo info, bool _) {
  //   setState(() {
  //     _imageInfo = info;
  //   });

  //   final scrollToEnd = context.read<void Function(Message)>();
  //   scrollToEnd(widget.message);
  // }

  // void _catchError(Object error, StackTrace? stackTrace) {}

  @override
  void dispose() {
    // _imageStream.removeListener(
    //   ImageStreamListener(_updateImage, onError: _catchError),
    // );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 300, minWidth: 170),
          decoration: BoxDecoration(
            color: Colors.grey[400],
          ),
          child: AspectRatio(
            aspectRatio: _aspectRatio,
            child: _bmp == null
                ? const SizedBox()
                : Image.memory(
                    _bmp!,
                    fit: BoxFit.fill,
                  ),
          ),
        ),
      );
}
