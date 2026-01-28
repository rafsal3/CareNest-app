import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';

  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Save the authentication token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieve the stored authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete the stored authentication token (logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if a token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
