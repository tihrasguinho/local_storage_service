abstract class LocalStorageService {
  /// Get a value as [T] from local storage
  T? get<T>(String key);

  /// Put a value as type [T] on local storage!
  Future<T?> put<T>(String key, T value);

  /// Delete a value from local storage with [key] given!
  Future<void> delete(String key);

  /// Check if value exists on local storage based on [key] given!
  bool exists(String key);
}
