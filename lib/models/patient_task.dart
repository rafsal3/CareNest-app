import 'package:equatable/equatable.dart';

enum TaskStatus { pending, done, skipped, unknown }

class PatientTask extends Equatable {
  final int id;
  final int patientId;
  final int doctorId;
  final String description;
  final TaskStatus status;
  final DateTime? completedAt;
  final DateTime? skippedAt;
  final DateTime createdAt;

  const PatientTask({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.description,
    required this.status,
    this.completedAt,
    this.skippedAt,
    required this.createdAt,
  });

  factory PatientTask.fromJson(Map<String, dynamic> json) {
    return PatientTask(
      id: json['id'] as int,
      patientId: json['patientId'] as int,
      doctorId: json['doctorId'] as int,
      description: json['description'] as String,
      status: _parseStatus(json['status'] as String?),
      completedAt:
          json['completedAt'] != null
              ? DateTime.tryParse(json['completedAt'] as String)
              : null,
      skippedAt:
          json['skippedAt'] != null
              ? DateTime.tryParse(json['skippedAt'] as String)
              : null,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'description': description,
      'status': status.toString().split('.').last.toUpperCase(),
      'completedAt': completedAt?.toIso8601String(),
      'skippedAt': skippedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static TaskStatus _parseStatus(String? status) {
    if (status == null) return TaskStatus.unknown;
    switch (status.toUpperCase()) {
      case 'PENDING':
        return TaskStatus.pending;
      case 'DONE':
        return TaskStatus.done;
      case 'SKIPPED':
        return TaskStatus.skipped;
      default:
        return TaskStatus.unknown;
    }
  }

  @override
  List<Object?> get props => [
    id,
    patientId,
    doctorId,
    description,
    status,
    completedAt,
    skippedAt,
    createdAt,
  ];
}
