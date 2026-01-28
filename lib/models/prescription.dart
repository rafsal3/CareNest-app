import 'package:equatable/equatable.dart';
import 'medicine.dart';
import 'user.dart';

enum PrescriptionStatus { active, completed, unknown }

class Prescription extends Equatable {
  final int id;
  final int medicineId;
  final int patientId;
  final int doctorId;
  final String dosage;
  final String frequency;
  final String duration;
  final PrescriptionStatus status;
  final DateTime prescribedAt;

  // Relations
  final Medicine? medicine;
  final User? patient;
  final User? doctor;

  const Prescription({
    required this.id,
    required this.medicineId,
    required this.patientId,
    required this.doctorId,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.status,
    required this.prescribedAt,
    this.medicine,
    this.patient,
    this.doctor,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as int,
      medicineId: json['medicineId'] as int,
      patientId: json['patientId'] as int,
      doctorId: json['doctorId'] as int,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      status: _parseStatus(json['status'] as String?),
      prescribedAt:
          DateTime.tryParse(json['prescribedAt'] as String) ?? DateTime.now(),
      medicine:
          json['medicine'] != null ? Medicine.fromJson(json['medicine']) : null,
      patient: json['patient'] != null ? User.fromJson(json['patient']) : null,
      doctor: json['doctor'] != null ? User.fromJson(json['doctor']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'patientId': patientId,
      'doctorId': doctorId,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'status': status.toString().split('.').last.toUpperCase(),
      'prescribedAt': prescribedAt.toIso8601String(),
      'medicine': medicine?.toJson(),
      'patient': patient?.toJson(),
      'doctor': doctor?.toJson(),
    };
  }

  static PrescriptionStatus _parseStatus(String? status) {
    if (status == null) return PrescriptionStatus.unknown;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return PrescriptionStatus.active;
      case 'COMPLETED':
        return PrescriptionStatus.completed;
      default:
        return PrescriptionStatus.unknown;
    }
  }

  @override
  List<Object?> get props => [
    id,
    medicineId,
    patientId,
    doctorId,
    dosage,
    frequency,
    duration,
    status,
    prescribedAt,
    medicine,
    patient,
    doctor,
  ];
}
