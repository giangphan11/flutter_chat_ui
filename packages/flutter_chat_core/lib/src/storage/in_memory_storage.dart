import 'storage.dart';

class InMemoryStorage implements Storage {
  final Map<String, Object> _storage = {};

  @override
  Future<void> set(String key, Object value) async {
    _storage[key] = value;
  }

  @override
  Future<Object?> get(String key) async =>
      _storage.containsKey(key) ? _storage[key] : null;

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async => _storage.containsKey(key);
}
