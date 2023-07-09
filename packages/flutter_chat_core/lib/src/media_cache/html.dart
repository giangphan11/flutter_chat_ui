import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
// ignore: uri_does_not_exist
import 'dart:indexed_db';
import 'dart:typed_data';

import 'base_media_cache.dart';

class MediaCache extends BaseMediaCache {
  // ignore: undefined_class
  Database? _db;
  Completer<void>? _dbOpenCompleter;

  MediaCache() {
    _open();
  }

  // ignore: undefined_class
  Future<void> _onUpgradeNeeded(VersionChangeEvent event) async {
    _db = event.target.result;
    _db?.createObjectStore('media');
  }

  Future<void> _open() async {
    // ignore: undefined_identifier
    if (!IdbFactory.supported || _dbOpenCompleter != null) {
      return;
    }

    _dbOpenCompleter = Completer<void>();

    try {
      _db = await window.indexedDB!.open(
        'flyer_chat_media_db',
        version: 1,
        onUpgradeNeeded: _onUpgradeNeeded,
      );

      _dbOpenCompleter?.complete();
    } catch (e) {
      _dbOpenCompleter?.completeError(e);
    } finally {
      _dbOpenCompleter = null;
    }
  }

  Future<void> _ensureDbOpen() async {
    if (_db == null) {
      if (_dbOpenCompleter != null) {
        await _dbOpenCompleter!.future;
      } else {
        await _open();
      }
    }
  }

  @override
  Future<void> set(String key, Map<String, Uint8List> value) async {
    await _ensureDbOpen();

    final transaction = _db!.transaction('media', 'readwrite');
    final store = transaction.objectStore('media');
    return store.put(value, key);
  }

  @override
  Future<void> update(String key, Map<String, Uint8List> value) async {
    await _ensureDbOpen();

    final transaction = _db!.transaction('media', 'readwrite');
    final store = transaction.objectStore('media');

    try {
      final existingEntry = await store.getObject(key);
      if (existingEntry is Map) {
        value.forEach((subKey, data) {
          existingEntry[subKey] = data;
        });
        return store.put(existingEntry, key);
      } else {
        return store.put(value, key);
      }
    } catch (e) {
      return Future.error(Exception('Failed to update media cache: $e'));
    }
  }

  @override
  Future<Map<String, Uint8List>?> get(String key) async {
    await _ensureDbOpen();

    final transaction = _db!.transaction('media', 'readonly');
    final store = transaction.objectStore('media');

    try {
      final data = await store.getObject(key);
      if (data is Map) {
        return data.map(
          (subKey, value) => MapEntry(
            subKey,
            value as Uint8List,
          ),
        );
      }
      return null;
    } catch (e) {
      return Future.error(Exception('Failed to update media cache: $e'));
    }
  }
}
