import 'secure_store.dart';

class TokenStore {
  TokenStore(this._store);

  static const accessKey = 'access_token';
  static const refreshKey = 'refresh_token';

  final SecureStore _store;
  final List<void Function()> _onCleared = [];

  void addOnCleared(void Function() listener) => _onCleared.add(listener);

  void removeOnCleared(void Function() listener) => _onCleared.remove(listener);

  Future<String?> readAccess() => _store.read(accessKey);

  Future<String?> readRefresh() => _store.read(refreshKey);

  Future<void> write({required String access, required String refresh}) async {
    await _store.write(accessKey, access);
    await _store.write(refreshKey, refresh);
  }

  Future<void> clear() async {
    await _store.delete(accessKey);
    await _store.delete(refreshKey);
    for (final listener in List<void Function()>.of(_onCleared)) {
      listener();
    }
  }
}
