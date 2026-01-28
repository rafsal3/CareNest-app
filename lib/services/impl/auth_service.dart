import '../../models/user.dart';
import '../interfaces/auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  AuthService();

  @override
  Future<User> login(String email, String password) async {
    // Dummy login
    return const User(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
      role: UserRole.patient,
    );
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    // Dummy register
    return User(id: 1, name: name, email: email, role: role);
  }

  @override
  Future<User> getProfile() async {
    return const User(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
      role: UserRole.patient,
    );
  }

  @override
  Future<void> logout() async {
    // No-op
  }

  @override
  Future<bool> isAuthenticated() async {
    return true; // Always authenticated
  }
}
