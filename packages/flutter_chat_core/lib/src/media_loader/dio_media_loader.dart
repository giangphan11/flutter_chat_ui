import 'dart:async';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

import '../storage/storage.dart';
import 'media_loader.dart';

class DioMediaLoader extends MediaLoader {
  late Dio _dio;
  final Map<String, StreamController<int>> _activeDownloads = {};

  DioMediaLoader([BaseOptions? options]) {
    _dio = Dio(options);
  }

  Future<void> _downloadAndSave(
    String url,
    StreamController<int> controller,
    Storage storage,
  ) async {
    try {
      final directory = await getApplicationCacheDirectory();

      final uri = Uri.parse(url);
      final name = uri.pathSegments.last;
      final path = '${directory.path}/$name';

      final possiblyExistingFile = XFile(path);
      final exists = await possiblyExistingFile.length() > 0;

      if (exists) {
        await controller.close();
        _activeDownloads.remove(url);
        return;
      }

      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (count, total) {
          if (total <= 0) return;
          final progress = (count / total * 100).round();
          controller.sink.add(progress);
        },
      );

      final bytes = response.data as Uint8List;

      final contentType = response.headers.value(Headers.contentTypeHeader);
      final mimeType = contentType ??
          lookupMimeType(url, headerBytes: bytes.take(16).toList());

      final file = XFile.fromData(
        bytes,
        mimeType: mimeType,
        name: name,
        length: bytes.length,
        lastModified: DateTime.now(),
        path: path,
      );
      await file.saveTo(path);
      await storage.set(name, {'path': path});
    } catch (error) {
      controller.sink.addError(error);
    } finally {
      await controller.close();
      _activeDownloads.remove(url);
    }
  }

  @override
  Stream<int> download(String url, Storage storage) {
    if (_activeDownloads.containsKey(url)) {
      return _activeDownloads[url]!.stream;
    }

    final controller = StreamController<int>.broadcast();
    _activeDownloads[url] = controller;

    _downloadAndSave(url, controller, storage);

    return controller.stream;
  }
}
