abstract class Storage {
  Future<void> set(String key, Object value);
  Future<Object?> get(String key);
  Future<void> remove(String key);
  Future<bool> containsKey(String key);
}
