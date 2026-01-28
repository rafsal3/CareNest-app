import '../../models/medicine.dart';

abstract class MedicineServiceInterface {
  /// Search for medicines by name or generic name
  Future<List<Medicine>> searchMedicines(String query);

  /// Get detailed information for a specific medicine
  Future<Medicine> getMedicineDetails(int medicineId);

  /// Fetch all available medicines (paginated commonly, but list for now)
  Future<List<Medicine>> getAllMedicines();

  /// Get list of unique medicine types
  Future<List<String>> getMedicineTypes();

  /// Temporary method to test backend connectivity
  Future<int> testFetchMedicinesCount();

  /// Update existing medicine
  Future<Medicine> updateMedicine(int id, Map<String, dynamic> updates);

  /// Create a test medicine for persistence check
  Future<Medicine> createMedicine(String name, String type);
  Future<Medicine> createTestMedicine(String name, String type);

  /// Fetch all medicines with debug logging
  Future<List<Medicine>> testFetchAllMedicines();

  /// Delete a medicine by ID
  Future<void> deleteMedicine(int id);
}
