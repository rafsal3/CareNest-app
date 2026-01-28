import '../../models/user.dart';
import '../../network/api_client.dart';
import '../../storage/token_storage.dart';
import '../interfaces/auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthService({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  @override
  Future<User> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    // Safety check for success flag
    if (response is Map<String, dynamic> && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final token = data['token']?.toString() ?? '';
      final userData = data['user'] as Map<String, dynamic>? ?? {};

      if (token.isNotEmpty) {
        await _tokenStorage.saveToken(token);
      }
      return User.fromJson(userData);
    }

    throw Exception('Login failed: Invalid response format');
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
        'role': role.toString().split('.').last.toUpperCase(),
      },
    );

    if (response is Map<String, dynamic> && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final token = data['token']?.toString() ?? '';
      final userData = data['user'] as Map<String, dynamic>? ?? {};

      if (token.isNotEmpty) {
        await _tokenStorage.saveToken(token);
      }
      return User.fromJson(userData);
    }

    throw Exception('Registration failed: Invalid response format');
  }

  @override
  Future<User> getProfile() async {
    final response = await _apiClient.get('/auth/profile');

    if (response is Map<String, dynamic> && response['success'] == true) {
      final userData = response['data'] as Map<String, dynamic>? ?? {};
      return User.fromJson(userData);
    }

    throw Exception('Failed to fetch profile: Invalid response format');
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
