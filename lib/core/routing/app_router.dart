import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_home_screen.dart';
import '../../features/auth/domain/app_auth_state.dart';
import '../../features/auth/domain/auth_providers.dart';
import '../../features/auth/presentation/auth_loading_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/bookings/presentation/booking_calendar_screen.dart';
import '../../features/bookings/presentation/booking_detail_screen.dart';
import '../../features/bookings/presentation/my_bookings_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import 'app_routes.dart';

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen<AppAuthState>(appAuthProvider, (_, _) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final auth = _ref.read(appAuthProvider);
    final location = state.uri.path;

    if (auth.isLoading) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final onSplash = location == AppRoutes.splash;
    final onLogin = location == AppRoutes.login;
    // startsWith covers all admin sub-routes (e.g. /admin/bookings)
    final onAdmin = location.startsWith(AppRoutes.admin);

    if (!auth.isAuthenticated) {
      if (onLogin) return null;
      return AppRoutes.login;
    }

    if (onSplash || onLogin) {
      return auth.isSuperAdmin ? AppRoutes.admin : AppRoutes.home;
    }

    // Regular user must not reach the admin route
    if (onAdmin && !auth.isSuperAdmin) {
      return AppRoutes.home;
    }

    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AuthLoadingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.booking,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: BookingCalendarScreen()),
      ),
      GoRoute(
        path: AppRoutes.myBookings,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: MyBookingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.bookingDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['bookingId']!;
          return NoTransitionPage(child: BookingDetailScreen(bookingId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.admin,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AdminHomeScreen()),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text(state.error.toString()))),
  );
});
