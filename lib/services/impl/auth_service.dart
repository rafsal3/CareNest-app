import '../../models/user.dart';

import '../../storage/token_storage.dart';
import '../interfaces/auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  final TokenStorage _tokenStorage;

  AuthService({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage;

  @override
  Future<User> login(String email, String password) async {
    // Local authentication check
    if (email == 'user@gmail.com' && password == 'password123') {
      const token = 'dummy_token_12345';

      await _tokenStorage.saveToken(token);

      return const User(
        id: 1,
        email: 'user@gmail.com',
        name: 'Local User',
        role: UserRole.patient,
      );
    }

    throw Exception('Login failed: Invalid credentials');
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    // Local auth does not support registration
    throw Exception(
      'Registration not supported in local mode. Please login with user@gmail.com / password123',
    );
  }

  @override
  Future<User> getProfile() async {
    // Simulate profile fetch from local data
    final hasToken = await _tokenStorage.hasToken();

    if (hasToken) {
      return const User(
        id: 1,
        email: 'user@gmail.com',
        name: 'Local User',
        role: UserRole.patient,
      );
    }

    throw Exception('Failed to fetch profile: User not authenticated');
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _tokenStorage.hasToken();
  }
}
