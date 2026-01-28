import '../../models/user.dart';

abstract class AuthServiceInterface {
  /// Attempt to login with email and password
  /// Returns the logged in User and stores the token internally
  Future<User> login(String email, String password);

  /// Register a new user
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });

  /// Get the current user profile using the stored token
  Future<User> getProfile();

  /// Logout the current user and clear stored tokens
  Future<void> logout();

  /// Check if a user is currently authenticated
  Future<bool> isAuthenticated();
}
