import '../../models/prescription.dart';
import '../../network/api_client.dart';
import '../interfaces/prescription_service_interface.dart';

class PrescriptionService implements PrescriptionServiceInterface {
  final ApiClient _apiClient;

  PrescriptionService({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Prescription>> fetchPatientPrescriptions(
    int patientId, {
    bool activeOnly = false,
  }) async {
    final response = await _apiClient.get(
      '/prescriptions',
      queryParameters: {
        'patientId': patientId,
        if (activeOnly) 'status': 'ACTIVE',
      },
    );

    // Backend returns: { success: true, data: [ ... ] }
    if (response is Map<String, dynamic> && response['success'] == true) {
      final List<dynamic> data = response['data'] as List<dynamic>;
      return data.map((json) => Prescription.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch patient prescriptions');
  }

  @override
  Future<List<Prescription>> fetchDoctorPrescriptions(
    int doctorId, {
    bool activeOnly = false,
  }) async {
    final response = await _apiClient.get(
      '/prescriptions',
      queryParameters: {
        'doctorId': doctorId,
        if (activeOnly) 'status': 'ACTIVE',
      },
    );

    if (response is Map<String, dynamic> && response['success'] == true) {
      final List<dynamic> data = response['data'] as List<dynamic>;
      return data.map((json) => Prescription.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch doctor prescriptions');
  }

  @override
  Future<Prescription> getPrescription(int prescriptionId) async {
    final response = await _apiClient.get('/prescriptions/$prescriptionId');

    // Backend returns: { success: true, data: { ... } }
    if (response is Map<String, dynamic> && response['success'] == true) {
      return Prescription.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to fetch prescription details');
  }

  @override
  Future<void> markPrescriptionCompleted(int prescriptionId) async {
    await _apiClient.patch(
      // Assuming PATCH exist or using PUT
      '/prescriptions/$prescriptionId',
      data: {'status': 'COMPLETED'},
    );
  }

  @override
  Future<void> activatePrescription(int prescriptionId) async {
    await _apiClient.patch(
      '/prescriptions/$prescriptionId',
      data: {'status': 'ACTIVE'},
    );
  }

  @override
  Future<Prescription> createPrescription(Prescription prescription) async {
    // Note: Prescription model toJson might include ID which should be stripped/ignored by backend for creation
    // Or we should separate CreatePrescriptionDto. For now sending toJson.
    final response = await _apiClient.post(
      '/prescriptions',
      data: prescription.toJson(),
    );

    if (response is Map<String, dynamic> && response['success'] == true) {
      return Prescription.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to create prescription');
  }
}
