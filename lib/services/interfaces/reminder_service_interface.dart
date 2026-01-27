import '../../models/pill_reminder.dart';

abstract class IReminderService {
  Future<void> init();
  Future<void> scheduleReminder(PillReminder reminder);
  Future<void> cancelReminder(PillReminder reminder);
  Future<void> cancelAll();
}
