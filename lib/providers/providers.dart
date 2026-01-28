import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/reminder_service.dart';
import '../services/interfaces/storage_service_interface.dart';
import '../services/interfaces/reminder_service_interface.dart';
import 'package:flutter/material.dart';
import '../models/pill_reminder.dart';
import '../models/activity.dart';
import '../network/api_client.dart';
import '../network/dio_api_client.dart';
import '../storage/token_storage.dart';
import '../services/impl/medicine_service.dart';
import '../services/impl/auth_service.dart';
import '../services/interfaces/medicine_service_interface.dart';
import '../services/interfaces/auth_service_interface.dart';
import '../models/user.dart';
import '../models/medicine.dart';
import '../models/medicine_draft.dart';

// Services Providers
final storageServiceProvider = Provider<IStorageService>((ref) {
  return StorageService();
});

final reminderServiceProvider = Provider<IReminderService>((ref) {
  return ReminderService();
});

// Network & Storage
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final baseUrl =
      Platform.isAndroid
          ? 'http://10.0.2.2:3000/api'
          : 'http://localhost:3000/api';

  return DioApiClient(baseUrl: baseUrl, tokenStorage: tokenStorage);
});

final medicineServiceProvider = Provider<MedicineServiceInterface>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return MedicineService(storageService: storageService);
});

final authServiceProvider = Provider<AuthServiceInterface>((ref) {
  return AuthService();
});

// Auth State
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error, // Nullable override
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthServiceInterface _authService;

  AuthNotifier(this._authService) : super(const AuthState(isLoading: true)) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Always authenticated locally
    state = state.copyWith(isLoading: false, isAuthenticated: true);
    // Determine dummy profile
    final user = await _authService.getProfile();
    state = state.copyWith(user: user);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    // No-op for local mode really, but let's keep it clean
    await _authService.logout();
    // In local storage mode without auth, maybe we don't actually logout?
    // Or we just stay authenticated.
    // For now, let's keep them authenticated.
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Reminder Controller
class ReminderNotifier extends AsyncNotifier<List<PillReminder>> {
  late final IStorageService _storageService;
  late final IReminderService _reminderService;

  @override
  Future<List<PillReminder>> build() async {
    _storageService = ref.watch(storageServiceProvider);
    _reminderService = ref.watch(reminderServiceProvider);

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

  Future<void> saveMedicineFromDraft(MedicineDraft draft) async {
    final currentList = state.value ?? [];
    // Don't set loading state to avoid UI flicker/reset

    // Create local reminders from draft
    final newReminders = <PillReminder>[];
    for (final time in draft.scheduleTimes) {
      newReminders.add(
        PillReminder(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              time.millisecondsSinceEpoch.toString(), // unique id
          medicineName: draft.name ?? 'Unknown Medicine',
          dosage: draft.dosage ?? 'As prescribed',
          frequency: '${draft.frequencyPerDay ?? 1}x daily', // Added frequency
          time: time,
          isActive: true,
        ),
      );
    }

    // We update state immediately (Optimistic)
    final combinedList = [...currentList, ...newReminders];
    state = AsyncValue.data(combinedList);

    try {
      // 1. Persist to Local Storage
      await _storageService.saveReminders(combinedList);

      // 2. Schedule Notifications
      for (final reminder in newReminders) {
        await _reminderService.scheduleReminder(reminder);
      }

      // Also save the medicine itself to the medicines list
      final medicineService = ref.read(medicineServiceProvider);
      await medicineService.createMedicine(
        draft.name ?? 'Unknown',
        'Tablet', // Default
      );
    } catch (e) {
      debugPrint('Error saving draft: $e');
    }
  }

  // Removed backend sync

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

class MedicinesNotifier extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async {
    return _loadMedicines();
  }

  Future<List<Medicine>> _loadMedicines() async {
    final storage = ref.read(storageServiceProvider);
    // Remove backend fetching as requested, load from local storage
    return storage.getMedicines();
  }

  Future<void> addMedicine(Medicine medicine) async {
    final currentList = state.value ?? [];

    // Optimistic update
    final newList = [...currentList, medicine];
    state = AsyncValue.data(newList);

    // Save to local storage
    try {
      final storage = ref.read(storageServiceProvider);
      await storage.saveMedicines(newList);
    } catch (e) {
      debugPrint('Error saving medicine locally: $e');
    }
  }

  Future<void> updateMedicineLocally(Medicine medicine) async {
    final currentList = state.value ?? [];
    final newList =
        currentList.map((m) => m.id == medicine.id ? medicine : m).toList();
    state = AsyncValue.data(newList);

    try {
      final storage = ref.read(storageServiceProvider);
      await storage.saveMedicines(newList);
    } catch (e) {
      debugPrint('Error saving medicine locally: $e');
    }
  }

  Future<void> deleteMedicine(int id) async {
    final previousState = state.value;
    if (previousState == null) return;

    // Optimistic Update
    final newList = previousState.where((m) => m.id != id).toList();
    state = AsyncValue.data(newList);

    try {
      // Update local storage
      final storage = ref.read(storageServiceProvider);
      await storage.saveMedicines(newList);

      // We optinally might want to delete from backend too, but for this task
      // we prioritize local consistency.
      // await ref.read(medicineServiceProvider).deleteMedicine(id);
    } catch (e) {
      // If local save fails, maybe revert?
      // state = AsyncValue.data(previousState);
      debugPrint('Error deleting medicine locally: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadMedicines());
  }
}

final medicinesProvider =
    AsyncNotifierProvider<MedicinesNotifier, List<Medicine>>(() {
      return MedicinesNotifier();
    });
