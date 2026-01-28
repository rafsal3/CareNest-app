import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'services/storage_service.dart';
import 'services/reminder_service.dart';
import 'providers/providers.dart';
import 'widgets/bootstrap_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Create service instances synchronously
  final storageService = StorageService();
  final reminderService = ReminderService();

  // Run app immediately without awaiting initialization
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        reminderServiceProvider.overrideWithValue(reminderService),
      ],
      // Wrap MyApp with BootstrapWrapper to handle async init
      child: const BootstrapWrapper(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'CareNest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
