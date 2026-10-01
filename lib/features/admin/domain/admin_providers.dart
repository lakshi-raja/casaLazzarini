import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:casa_lazzarini/shared/models/booking.dart';
import 'package:casa_lazzarini/shared/models/booking_status.dart';
import 'package:casa_lazzarini/shared/models/profile.dart';
import 'package:casa_lazzarini/shared/models/suite.dart';

import '../data/admin_repository.dart';
import 'booking_filter.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final adminRepositoryProvider = Provider<AdminRepository>(
  (_) => AdminRepository(),
);

// ── Filter ────────────────────────────────────────────────────────────────────

class BookingFilterNotifier extends StateNotifier<BookingFilter> {
  BookingFilterNotifier() : super(const BookingFilter());

  void setStatus(BookingStatus? status) => state = state.withStatus(status);

  void setSuiteId(String? id) => state = state.withSuiteId(id);

  void setDateRange(DateTime? from, DateTime? to) =>
      state = state.withDateRange(from, to);

  void clear() => state = const BookingFilter();
}

final bookingFilterProvider =
    StateNotifierProvider<BookingFilterNotifier, BookingFilter>(
      (_) => BookingFilterNotifier(),
    );

// ── Data providers ────────────────────────────────────────────────────────────

final adminBookingsProvider = FutureProvider<List<Booking>>((ref) {
  final filter = ref.watch(bookingFilterProvider);
  return ref.watch(adminRepositoryProvider).fetchBookings(filter: filter);
});

final adminSuitesProvider = FutureProvider<List<Suite>>(
  (ref) => ref.watch(adminRepositoryProvider).fetchSuites(),
);

final adminProfilesProvider = FutureProvider<List<Profile>>(
  (ref) => ref.watch(adminRepositoryProvider).fetchProfiles(),
);

// ── Dashboard stats ───────────────────────────────────────────────────────────

@immutable
class AdminDashboardStats {
  final int activeBookings;
  final int cancelledBookings;
  final int totalSuites;
  final int activeSuites;
  final int totalProfiles;
  final List<Booking> recentBookings;

  const AdminDashboardStats({
    required this.activeBookings,
    required this.cancelledBookings,
    required this.totalSuites,
    required this.activeSuites,
    required this.totalProfiles,
    required this.recentBookings,
  });
}

// Fetches all data independently of the bookings-list filter.
final adminDashboardProvider = FutureProvider<AdminDashboardStats>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  final bookings = await repo.fetchBookings();
  final suites = await repo.fetchSuites();
  final profiles = await repo.fetchProfiles();

  return AdminDashboardStats(
    activeBookings: bookings
        .where((b) => b.status == BookingStatus.active)
        .length,
    cancelledBookings: bookings
        .where((b) => b.status == BookingStatus.cancelled)
        .length,
    totalSuites: suites.length,
    activeSuites: suites.where((s) => s.active).length,
    totalProfiles: profiles.length,
    recentBookings: bookings.take(5).toList(),
  );
});
