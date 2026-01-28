import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pill_reminder.dart';
import '../models/medicine.dart';
import 'interfaces/storage_service_interface.dart';

class StorageService implements IStorageService {
  static const String _remindersKey = 'pill_reminders';
  static const String _medicinesKey = 'medicines';
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<PillReminder>> getReminders() async {
    try {
      final String? jsonString = _prefs.getString(_remindersKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => PillReminder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading reminders: $e');
      return [];
    }
  }

  @override
  Future<void> saveReminders(List<PillReminder> reminders) async {
    try {
      final String jsonString = jsonEncode(
        reminders.map((r) => r.toJson()).toList(),
      );
      await _prefs.setString(_remindersKey, jsonString);
    } catch (e) {
      debugPrint('Error saving reminders: $e');
      throw Exception('Failed to save reminders');
    }
  }

  @override
  Future<List<Medicine>> getMedicines() async {
    try {
      final String? jsonString = _prefs.getString(_medicinesKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Medicine.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading medicines: $e');
      return [];
    }
  }

  @override
  Future<void> saveMedicines(List<Medicine> medicines) async {
    try {
      final String jsonString = jsonEncode(
        medicines.map((m) => m.toJson()).toList(),
      );
      await _prefs.setString(_medicinesKey, jsonString);
    } catch (e) {
      debugPrint('Error saving medicines: $e');
      throw Exception('Failed to save medicines');
    }
  }
}
