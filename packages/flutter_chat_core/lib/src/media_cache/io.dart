import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'base_media_cache.dart';

class MediaCache extends BaseMediaCache {
  @override
  Future<void> set(String key, Map<String, Uint8List> value) async {
    final cache = await getApplicationCacheDirectory();
    final media = Directory('${cache.path}/flyer-chat-media/$key');

    if (await media.exists()) {
      final existingFiles = media.list();
      await for (final file in existingFiles) {
        if (file is File) {
          await file.delete();
        }
      }
    } else {
      await media.create(recursive: true);
    }

    final files = value.entries.map((entry) {
      final path = '${media.path}/${entry.key}';
      final file = File(path);
      return file.writeAsBytes(entry.value);
    });

    await Future.wait(files);
  }

  @override
  Future<void> update(String key, Map<String, Uint8List> value) async {
    final cache = await getApplicationCacheDirectory();
    final media = Directory('${cache.path}/flyer-chat-media/$key');

    if (!await media.exists()) {
      await media.create(recursive: true);
    }

    final files = value.entries.map((entry) {
      final path = '${media.path}/${entry.key}';
      final file = File(path);
      return file.writeAsBytes(entry.value);
    });

    await Future.wait(files);
  }

  @override
  Future<Map<String, Uint8List>?> get(String key) async {
    try {
      final cache = await getApplicationCacheDirectory();
      final directory = Directory('${cache.path}/flyer-chat-media/$key');

      if (await directory.exists()) {
        final resultMap = {} as Map<String, Uint8List>;

        await for (final entity in directory.list()) {
          if (entity is File) {
            final fileName = entity.uri.pathSegments.last;
            final fileData = await entity.readAsBytes();
            resultMap[fileName] = fileData;
          }
        }

        return resultMap;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
