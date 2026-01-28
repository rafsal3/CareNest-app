import 'package:equatable/equatable.dart';

class ApiError extends Equatable {
  final String code;
  final String message;
  final String? timestamp;

  const ApiError({required this.code, required this.message, this.timestamp});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An unexpected error occurred',
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message, 'timestamp': timestamp};
  }

  @override
  List<Object?> get props => [code, message, timestamp];
}
