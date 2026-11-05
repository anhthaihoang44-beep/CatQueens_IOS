abstract class StorageService {
  Future<void> init();
  Future<void> set<T>(String box, String key, T value);
  T? get<T>(String box, String key, [T? defaultValue]);
  Future<void> remove(String box, String key);
  Future<void> clear(String box);
}

