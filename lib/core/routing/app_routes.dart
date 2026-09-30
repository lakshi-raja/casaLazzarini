abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  // Phase 2 — Booking
  static const String booking = '/booking';
  static const String myBookings = '/booking/list';
  static const String bookingDetail = '/booking/:bookingId';

  // Phase 3 — Admin
  static const String admin = '/admin';
  static const String adminBookings = '/admin/bookings';
}
