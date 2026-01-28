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
  final apiClient = ref.watch(apiClientProvider);
  return MedicineService(apiClient: apiClient);
});

final authServiceProvider = Provider<AuthServiceInterface>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthService(apiClient: apiClient, tokenStorage: tokenStorage);
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
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        // Optimistically set authenticated, then fetch profile
        state = state.copyWith(isLoading: false, isAuthenticated: true);
        try {
          final user = await _authService.getProfile();
          if (mounted) {
            state = state.copyWith(user: user);
          }
        } catch (_) {
          // If profile fetch fails but token exists, we might need re-login or just stay auth
          // ensuring we don't boot them out immediately if it's just a network blip,
          // but if 401 it should have been caught by interceptor ideally.
        }
      } else {
        state = state.copyWith(isLoading: false, isAuthenticated: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
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
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: false,
      user: null,
    );
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

    // fallback logic: "Mock" store is just our local StorageService
    // In a real app, we'd try await _medicineService.create(...) here.
    // For now, we simulate backend failure/success or just proceed to local save as the "Mock Store" is the source of truth for "Medicine Today" in this app currently.

    // We update state immediately (Optimistic)
    final combinedList = [...currentList, ...newReminders];
    state = AsyncValue.data(combinedList);

    try {
      // 1. Persist to Local Storage (This acts as our Mock Store / Cache)
      await _storageService.saveReminders(combinedList);

      // 2. Schedule Notifications
      for (final reminder in newReminders) {
        await _reminderService.scheduleReminder(reminder);
      }

      // 3. Attempt Backend Sync (Fire and Forget)
      _syncToBackend(draft);
    } catch (e) {
      // Revert if local save fails? Unlikely.
      debugPrint('Error saving draft: $e');
    }
  }

  Future<void> _syncToBackend(MedicineDraft draft) async {
    try {
      final medicineService = ref.read(medicineServiceProvider);
      // Determine type from dosage or just default
      // API requires name and type.
      // Note: Backend might deduplicate by name.
      debugPrint('🔄 [DIAGNOSTICS] Syncing to backend: ${draft.name}');
      final medicine = await medicineService.createMedicine(
        draft.name ?? 'Unknown',
        'Tablet', // Default type if not parsed
      );
      debugPrint('✅ [DIAGNOSTICS] Backend Sync Success: ${medicine.id}');

      // Optionally create reminders on backend too if that API exists
      // but for now we persisted medicine which is the requirement.
    } catch (e) {
      debugPrint('❌ [DIAGNOSTICS] Backend Sync Failed: $e');
      // We don't fail the UI flow because we have local storage
    }
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

class MedicinesNotifier extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async {
    return _fetchMedicines();
  }

  Future<List<Medicine>> _fetchMedicines() async {
    final service = ref.read(medicineServiceProvider);
    return service
        .testFetchAllMedicines(); // Or getAllMedicines if available/standardized
  }

  Future<void> deleteMedicine(int id) async {
    // Optimistic or Pessimistic?
    // Let's do pessimistic for safety with backend, or optimistic for UI responsiveness.
    // The prompt says "Remove item from UI immediately (optimistic update)".

    final previousState = state.value;
    if (previousState == null) return;

    // Optimistic Update
    state = AsyncValue.data(previousState.where((m) => m.id != id).toList());

    try {
      await ref.read(medicineServiceProvider).deleteMedicine(id);
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(previousState);
      // We can't easily show snackbar from here, so we rethrow to let UI handle it
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMedicines());
  }
}

final medicinesProvider =
    AsyncNotifierProvider<MedicinesNotifier, List<Medicine>>(() {
      return MedicinesNotifier();
    });
