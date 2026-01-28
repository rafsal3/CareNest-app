import 'dart:math';
import '../../models/medicine.dart';
import '../interfaces/medicine_service_interface.dart';
import '../interfaces/storage_service_interface.dart';

class MedicineService implements MedicineServiceInterface {
  final IStorageService _storageService;

  MedicineService({required IStorageService storageService})
    : _storageService = storageService;

  @override
  Future<List<Medicine>> searchMedicines(String query) async {
    final all = await _storageService.getMedicines();
    if (query.isEmpty) return all;
    return all
        .where(
          (m) =>
              m.name.toLowerCase().contains(query.toLowerCase()) ||
              (m.genericName?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();
  }

  @override
  Future<Medicine> getMedicineDetails(int medicineId) async {
    final all = await _storageService.getMedicines();
    try {
      return all.firstWhere((m) => m.id == medicineId);
    } catch (e) {
      throw Exception('Medicine not found');
    }
  }

  @override
  Future<List<Medicine>> getAllMedicines() async {
    return _storageService.getMedicines();
  }

  @override
  Future<List<String>> getMedicineTypes() async {
    final all = await _storageService.getMedicines();
    final types = all.map((m) => m.type).toSet().toList();
    return types.isEmpty ? ['Tablet', 'Capsule', 'Liquid', 'Topical'] : types;
  }

  @override
  Future<int> testFetchMedicinesCount() async {
    final all = await _storageService.getMedicines();
    return all.length;
  }

  @override
  Future<Medicine> createMedicine(String name, String type) async {
    final all = await _storageService.getMedicines();
    final int newId = all.isEmpty ? 1 : all.map((m) => m.id).reduce(max) + 1;

    final newMedicine = Medicine(
      id: newId,
      name: name,
      genericName: '',
      type: type,
    );

    final newList = [...all, newMedicine];
    await _storageService.saveMedicines(newList);
    return newMedicine;
  }

  @override
  Future<Medicine> updateMedicine(int id, Map<String, dynamic> updates) async {
    final all = await _storageService.getMedicines();
    final index = all.indexWhere((m) => m.id == id);
    if (index == -1) throw Exception('Medicine not found');

    final current = all[index];
    final currentJson = current.toJson();
    final updatedJson = {...currentJson, ...updates};
    // Ensure ID doesn't change
    updatedJson['id'] = id;

    final updatedMedicine = Medicine.fromJson(updatedJson);

    all[index] = updatedMedicine;
    await _storageService.saveMedicines(all);
    return updatedMedicine;
  }

  @override
  Future<Medicine> createTestMedicine(String name, String type) {
    return createMedicine(name, type);
  }

  @override
  Future<List<Medicine>> testFetchAllMedicines() {
    return getAllMedicines();
  }

  @override
  Future<void> deleteMedicine(int id) async {
    final all = await _storageService.getMedicines();
    final newList = all.where((m) => m.id != id).toList();
    if (newList.length != all.length) {
      await _storageService.saveMedicines(newList);
    }
  }
}
