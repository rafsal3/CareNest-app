import '../../models/prescription.dart';

abstract class PrescriptionServiceInterface {
  /// Fetch all prescriptions for a specific patient
  Future<List<Prescription>> fetchPatientPrescriptions(
    int patientId, {
    bool activeOnly = false,
  });

  /// Fetch all prescriptions created by a specific doctor
  Future<List<Prescription>> fetchDoctorPrescriptions(
    int doctorId, {
    bool activeOnly = false,
  });

  /// Get details of a single prescription
  Future<Prescription> getPrescription(int prescriptionId);

  /// Mark a prescription as completed (archived)
  Future<void> markPrescriptionCompleted(int prescriptionId);

  /// Activate a completed prescription
  Future<void> activatePrescription(int prescriptionId);

  /// Create a new prescription (Doctor only)
  Future<Prescription> createPrescription(Prescription prescription);
}
