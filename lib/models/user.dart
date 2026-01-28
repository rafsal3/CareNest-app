import 'package:equatable/equatable.dart';

enum UserRole { doctor, patient, unknown }

class User extends Equatable {
  final int id;
  final String email;
  final String name;
  final UserRole role;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      role: _parseRole(json['role'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last.toUpperCase(),
    };
  }

  static UserRole _parseRole(String? role) {
    if (role == null) return UserRole.unknown;
    switch (role.toUpperCase()) {
      case 'DOCTOR':
        return UserRole.doctor;
      case 'PATIENT':
        return UserRole.patient;
      default:
        return UserRole.unknown;
    }
  }

  @override
  List<Object?> get props => [id, email, name, role];
}
