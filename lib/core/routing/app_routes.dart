abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  // Phase 2 — Booking (routes registered by Phase 2 agent in app_router.dart)
  static const String booking = '/booking';
  static const String bookingDetail = '/booking/:bookingId';

  // Phase 3 — Admin (routes registered by Phase 3 agent in app_router.dart)
  static const String admin = '/admin';
  static const String adminBookings = '/admin/bookings';
}
