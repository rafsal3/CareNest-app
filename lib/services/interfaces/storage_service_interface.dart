import '../../models/pill_reminder.dart';

abstract class IStorageService {
  Future<void> init();
  Future<List<PillReminder>> getReminders();
  Future<void> saveReminders(List<PillReminder> reminders);
}
