import 'package:flutter/foundation.dart';
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
  Future<Medicine> createMedicine(String name, String type) async {
    try {
      final payload = {
        'name': name,
        'genericName': '',
        'type': type,
        'medicineType': type,
      };

      final response = await _apiClient.post('/medicines', data: payload);

      if (response is Map<String, dynamic> && response['success'] == true) {
        return Medicine.fromJson(response['data'] as Map<String, dynamic>);
      }
      throw Exception('Creation failed: Invalid response');
    } catch (e, stack) {
      debugPrint('❌ [MedicineService] Creation Error: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  @override
  Future<Medicine> updateMedicine(int id, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put('/medicines/$id', data: updates);
      if (response is Map<String, dynamic> && response['success'] == true) {
        return Medicine.fromJson(response['data'] as Map<String, dynamic>);
      }
      throw Exception('Update failed: Invalid response');
    } catch (e, stack) {
      debugPrint('❌ [MedicineService] Update Error: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  @override
  Future<Medicine> createTestMedicine(String name, String type) async {
    return createMedicine(name, type);
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
      debugPrint('❌ [MedicineService] Fetch Error: $e');
      debugPrint(stack.toString());
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
