import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/reminder_service.dart';
import '../services/interfaces/storage_service_interface.dart';
import '../services/interfaces/reminder_service_interface.dart';
import 'package:flutter/material.dart';
import '../models/pill_reminder.dart';
import '../models/activity.dart';

// Services Providers
final storageServiceProvider = Provider<IStorageService>((ref) {
  return StorageService();
});

final reminderServiceProvider = Provider<IReminderService>((ref) {
  return ReminderService();
});

// Reminder Controller
class ReminderNotifier extends AsyncNotifier<List<PillReminder>> {
  late final IStorageService _storageService;
  late final IReminderService _reminderService;

  @override
  Future<List<PillReminder>> build() async {
    _storageService = ref.watch(storageServiceProvider);
    _reminderService = ref.watch(reminderServiceProvider);

    // Initialize services if strictly needed here or ensure they are init at startup
    // For now assuming init happens at main or services are robust.
    // Ideally services init method should be called.
    // Let's call init here lazily if we want, or better, in main.

    return _storageService.getReminders();
  }

  Future<void> addReminder(PillReminder reminder) async {
    final currentList = state.value ?? [];
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final newList = [...currentList, reminder];
      await _storageService.saveReminders(newList);
      await _reminderService.scheduleReminder(reminder);
      return newList;
    });
  }

  Future<void> removeReminder(PillReminder reminder) async {
    final currentList = state.value ?? [];
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final newList = [
        for (final r in currentList)
          if (r.id != reminder.id) r,
      ];
      await _storageService.saveReminders(newList);
      await _reminderService.cancelReminder(reminder);
      return newList;
    });
  }

  Future<void> toggleReminder(PillReminder reminder) async {
    final currentList = state.value ?? [];
    // state = const AsyncValue.loading(); // Optional: might cause flicker for simple toggle

    state = await AsyncValue.guard(() async {
      final updatedReminder = reminder.copyWith(isActive: !reminder.isActive);
      final newList = [
        for (final r in currentList)
          if (r.id == reminder.id) updatedReminder else r,
      ];

      await _storageService.saveReminders(newList);

      if (updatedReminder.isActive) {
        await _reminderService.scheduleReminder(updatedReminder);
      } else {
        await _reminderService.cancelReminder(updatedReminder);
      }
      return newList;
    });
  }
}

final reminderProvider =
    AsyncNotifierProvider<ReminderNotifier, List<PillReminder>>(() {
      return ReminderNotifier();
    });

// Activity Controller
class ActivityNotifier extends AsyncNotifier<List<Activity>> {
  @override
  Future<List<Activity>> build() async {
    // Mock Data for now
    return [
      const Activity(
        id: '1',
        label: 'Morning Walk',
        isCompleted: false,
        icon: Icons.directions_walk,
      ),
      const Activity(
        id: '2',
        label: 'Breathing Exercises',
        isCompleted: false,
        icon: Icons.self_improvement,
      ),
      const Activity(
        id: '3',
        label: 'Drink Water',
        isCompleted: true,
        icon: Icons.local_drink,
      ),
    ];
  }

  Future<void> toggleActivity(String id) async {
    final currentList = state.value ?? [];

    // Optimistic update
    final updatedList =
        currentList.map((activity) {
          if (activity.id == id) {
            return activity.copyWith(isCompleted: !activity.isCompleted);
          }
          return activity;
        }).toList();

    state = AsyncValue.data(updatedList);
  }
}

final activityProvider =
    AsyncNotifierProvider<ActivityNotifier, List<Activity>>(() {
      return ActivityNotifier();
    });
