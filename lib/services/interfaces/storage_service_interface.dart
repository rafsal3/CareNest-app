import '../../models/pill_reminder.dart';
import '../../models/medicine.dart';

abstract class IStorageService {
  Future<void> init();
  Future<List<PillReminder>> getReminders();
  Future<void> saveReminders(List<PillReminder> reminders);
  Future<List<Medicine>> getMedicines();
  Future<void> saveMedicines(List<Medicine> medicines);
}
