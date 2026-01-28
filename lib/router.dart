import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/providers.dart';
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
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/edit_medicine_screen.dart';
import 'models/medicine.dart';
import 'models/medicine_draft.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    initialLocation: '/home',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isLoading = authState.isLoading;

      // If initializing, stay put or show splash (handled by BootstrapWrapper usually,
      // but router might run before BootstrapWrapper is done if we are not careful.
      // Actually we are wrapping MyApp in BootstrapWrapper, so MyApp builds first.
      // But routerConfig is needed by MaterialApp.
      // If we are loading, we might want to let the Loading screen handle it.
      if (isLoading) return null;

      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn) {
        if (!isLoggingIn) return '/login';
        return null; // Stay on login/register
      }

      if (isLoggingIn) {
        return '/home'; // Redirect to home if already logged in
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
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
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(0, 0.05);
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
      GoRoute(
        path: '/edit-medicine',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return EditMedicineScreen(
            medicine: extras?['medicine'] as Medicine?,
            draft: extras?['draft'] as MedicineDraft?,
            isNew: extras?['isNew'] ?? false,
          );
        },
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
