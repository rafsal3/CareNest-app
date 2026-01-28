import '../../models/medicine.dart';
import '../../network/api_client.dart';
import '../interfaces/medicine_service_interface.dart';

class MedicineService implements MedicineServiceInterface {
  final ApiClient _apiClient;

  MedicineService({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Medicine>> searchMedicines(String query) async {
    final response = await _apiClient.get(
      '/medicines',
      queryParameters: {'search': query},
    );

    if (response is Map<String, dynamic> && response['success'] == true) {
      final List<dynamic> data = response['data'] as List<dynamic>;
      return data.map((json) => Medicine.fromJson(json)).toList();
    }
    throw Exception('Failed to search medicines');
  }

  @override
  Future<Medicine> getMedicineDetails(int medicineId) async {
    final response = await _apiClient.get('/medicines/$medicineId');

    if (response is Map<String, dynamic> && response['success'] == true) {
      return Medicine.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to fetch medicine details');
  }

  @override
  Future<List<Medicine>> getAllMedicines() async {
    final response = await _apiClient.get('/medicines');

    if (response is Map<String, dynamic> && response['success'] == true) {
      final List<dynamic> data = response['data'] as List<dynamic>;
      return data.map((json) => Medicine.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch medicines');
  }

  @override
  Future<List<String>> getMedicineTypes() async {
    // Assuming backend endpoint /medicines/types exists or filtering locally
    // For Safety: We will fetch all and map types if specific endpoint fails in valid implementation
    // But let's assume valid endpoint first or a fixed list
    try {
      final response = await _apiClient.get('/medicines/types');
      if (response is Map<String, dynamic> && response['success'] == true) {
        return (response['data'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
    } catch (_) {
      // Fallback: Fetch all and extract
      final all = await getAllMedicines();
      return all.map((m) => m.type).toSet().toList();
    }

    return [];
  }

  @override
  Future<int> testFetchMedicinesCount() async {
    try {
      final response = await _apiClient.get('/medicines');

      if (response is Map<String, dynamic> && response['success'] == true) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data.length;
      }
      throw Exception('Response format invalid or success false');
    } catch (e, stack) {
      print('❌ [MedicineService] Test failed: $e');
      print(stack);
      rethrow;
    }
  }

  @override
  Future<Medicine> createTestMedicine(String name, String type) async {
    try {
      final payload = {
        'name': name,
        'genericName': 'Antigravity',
        'type': type,
        'medicineType': type,
      };

      final response = await _apiClient.post('/medicines', data: payload);

      if (response is Map<String, dynamic> && response['success'] == true) {
        return Medicine.fromJson(response['data'] as Map<String, dynamic>);
      }
      throw Exception('Creation failed: Invalid response');
    } catch (e, stack) {
      print('❌ [MedicineService] Creation Error: $e');
      print(stack);
      rethrow;
    }
  }

  @override
  Future<List<Medicine>> testFetchAllMedicines() async {
    try {
      final response = await _apiClient.get('/medicines');

      if (response is Map<String, dynamic> && response['success'] == true) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data.map((json) => Medicine.fromJson(json)).toList();
      }
      throw Exception('Fetch failed');
    } catch (e, stack) {
      print('❌ [MedicineService] Fetch Error: $e');
      print(stack);
      rethrow;
    }
  }

  @override
  Future<void> deleteMedicine(int id) async {
    try {
      await _apiClient.delete('/medicines/$id');
    } catch (e) {
      // ApiClient interceptor and error parsing should ideally return specific errors
      rethrow;
    }
  }
}
