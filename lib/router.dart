import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/meds_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/add_reminder_screen.dart';

import 'screens/chat_screen.dart';
import 'screens/emergency_support_screen.dart';
import 'widgets/scaffold_with_navigation.dart';
import 'screens/medicine_detail_screen.dart';
import 'screens/prescription_history_screen.dart';
import 'screens/prescription_detail_screen.dart';
import 'screens/appointment_detail_screen.dart';
import 'models/prescription.dart';
import 'models/pill_reminder.dart';

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
              builder: (context, state) => const PrescriptionHistoryScreen(),
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
      pageBuilder: (context, state) {
        final reminder = state.extra as PillReminder;
        return CustomTransitionPage(
          key: state.pageKey,
          child: MedicineDetailScreen(reminder: reminder),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0, 0.05); // Approx 30-40px depending on screen
            const end = Offset.zero;
            const curve = Curves.easeOut;

            var slideTween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var fadeTween = Tween(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
      },
    ),
    GoRoute(
      path: '/prescription-history',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PrescriptionHistoryScreen(),
    ),
    GoRoute(
      path: '/prescription-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final prescription = state.extra as Prescription;
        return PrescriptionDetailScreen(prescription: prescription);
      },
    ),
    GoRoute(
      path: '/appointment-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AppointmentDetailScreen(),
    ),
    GoRoute(
      path: '/emergency-support',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EmergencySupportScreen(),
    ),
    GoRoute(
      path: '/chat',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ChatScreen(),
    ),
  ],
);
