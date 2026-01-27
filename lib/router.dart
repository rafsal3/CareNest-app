import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/meds_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/add_reminder_screen.dart';
import 'screens/history_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/emergency_support_screen.dart';
import 'widgets/scaffold_with_navigation.dart';
import 'screens/medicine_detail_screen.dart';
import 'models/medicine.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/meds',
              builder: (context, state) => const MedsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/emergency',
              builder: (context, state) => const EmergencyScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/scan',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ScanScreen(),
    ),
    GoRoute(
      path: '/add-reminder',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddReminderScreen(),
    ),
    GoRoute(
      path: '/medicine-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final medicine = state.extra as Medicine;
        return MedicineDetailScreen(medicine: medicine);
      },
    ),
    GoRoute(
      path: '/emergency-support',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EmergencySupportScreen(),
    ),
  ],
);
