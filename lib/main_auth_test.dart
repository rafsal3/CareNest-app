import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'network/dio_api_client.dart';
import 'services/impl/auth_service.dart';
import 'storage/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AuthTestApp());
}

class AuthTestApp extends StatelessWidget {
  const AuthTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Auth Verification')),
        body: const AuthTestScreen(),
      ),
    );
  }
}

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  late final AuthService _authService;
  String _logs = '';

  @override
  void initState() {
    super.initState();
    _initService();
  }

  void _initService() {
    const storage = FlutterSecureStorage();
    final tokenStorage = TokenStorage(storage: storage);

    // Android Emulator uses 10.0.2.2, iOS Simulator uses localhost
    final baseUrl =
        Platform.isAndroid
            ? 'http://10.0.2.2:3000/api'
            : 'http://localhost:3000/api';

    final apiClient = DioApiClient(
      baseUrl: baseUrl,
      tokenStorage: tokenStorage,
    );

    _authService = AuthService(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    _log('Service Initialized');
  }

  void _log(String message) {
    setState(() {
      _logs += '$message\n\n';
    });
    print(message);
  }

  Future<void> _testLogin() async {
    try {
      _log('Attempting Login as patient@test.com...');
      final user = await _authService.login('patient@test.com', 'password123');
      _log('Login Success! User: ${user.name} (${user.role})');

      final isAuth = await _authService.isAuthenticated();
      _log('Is Authenticated: $isAuth');
    } catch (e) {
      _log('Login Failed: $e');
    }
  }

  Future<void> _testProfile() async {
    try {
      _log('Fetching Profile...');
      final user = await _authService.getProfile();
      _log('Profile Fetched! User: ${user.email}');
    } catch (e) {
      _log('Profile Fetch Failed: $e');
    }
  }

  Future<void> _testLogout() async {
    await _authService.logout();
    _log('Logged out.');
    final isAuth = await _authService.isAuthenticated();
    _log('Is Authenticated: $isAuth');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: _testLogin, child: const Text('Login')),
              ElevatedButton(
                onPressed: _testProfile,
                child: const Text('Profile'),
              ),
              ElevatedButton(
                onPressed: _testLogout,
                child: const Text('Logout'),
              ),
            ],
          ),
          const Divider(),
          Expanded(child: SingleChildScrollView(child: Text(_logs))),
        ],
      ),
    );
  }
}
