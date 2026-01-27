import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pill_reminder.dart';

class StorageService {
  static const String _remindersKey = 'pill_reminders';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<PillReminder>> getReminders() async {
    final String? jsonString = _prefs.getString(_remindersKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => PillReminder.fromJson(json)).toList();
  }

  Future<void> saveReminders(List<PillReminder> reminders) async {
    final String jsonString = jsonEncode(
      reminders.map((r) => r.toJson()).toList(),
    );
    await _prefs.setString(_remindersKey, jsonString);
  }
}

final storageService = StorageService();
