import 'dart:typed_data';

abstract class BaseMediaCache {
  Future<void> set(String key, Map<String, Uint8List> value);
  Future<void> update(String key, Map<String, Uint8List> value);
  Future<Map<String, Uint8List>?> get(String key);
}
