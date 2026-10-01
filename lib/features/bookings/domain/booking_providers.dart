import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../features/auth/domain/auth_providers.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/booking_type.dart';
import '../../../shared/models/suite.dart';
import '../../../shared/repositories/booking_repository.dart';
import '../../../shared/repositories/i_suite_repository.dart';
import '../../../shared/repositories/suite_repository.dart';
import 'i_booking_repository.dart';

final suiteRepositoryProvider = Provider<ISuiteRepository>((ref) {
  return SuiteRepository(Supabase.instance.client);
});

// Concrete provider used internally where admin methods are needed.
final _bookingRepositoryConcreteProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(Supabase.instance.client);
});

final bookingRepositoryProvider = Provider<IBookingRepository>((ref) {
  return ref.watch(_bookingRepositoryConcreteProvider);
});

final suitesProvider = FutureProvider<List<Suite>>((ref) {
  return ref.read(suiteRepositoryProvider).getActiveSuites();
});

/// The month currently displayed in the booking calendar (first day of month).
final calendarMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

/// All ACTIVE bookings for the currently selected calendar month.
final monthActiveBookingsProvider = FutureProvider.autoDispose<List<Booking>>((
  ref,
) {
  final month = ref.watch(calendarMonthProvider);
  final from = DateTime(month.year, month.month, 1);
  final to = DateTime(month.year, month.month + 1, 0); // last day of month
  return ref
      .read(_bookingRepositoryConcreteProvider)
      .fetchActiveBookings(from: from, to: to);
});

/// The authenticated user's own bookings, all statuses, newest first.
final myBookingsProvider = FutureProvider.autoDispose<List<Booking>>((
  ref,
) async {
  final auth = ref.watch(appAuthProvider);
  if (!auth.isAuthenticated || auth.profile == null) return [];
  return ref.read(bookingRepositoryProvider).getMyBookings();
});

/// Handles booking creation and cancellation.
class BookingActionsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Booking> createBooking({
    required String suiteId,
    required DateTime date,
    required BookingType type,
  }) async {
    final auth = ref.read(appAuthProvider);
    if (!auth.isAuthenticated || auth.profile == null) {
      throw const AuthenticationException('Non autenticato.');
    }
    state = const AsyncLoading();
    try {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .createBooking(suiteId: suiteId, date: date, type: type);
      state = const AsyncData(null);
      ref.invalidate(monthActiveBookingsProvider);
      ref.invalidate(myBookingsProvider);
      return booking;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    state = const AsyncLoading();
    try {
      await ref.read(bookingRepositoryProvider).cancelBooking(bookingId);
      state = const AsyncData(null);
      ref.invalidate(monthActiveBookingsProvider);
      ref.invalidate(myBookingsProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final bookingActionsProvider =
    AsyncNotifierProvider<BookingActionsNotifier, void>(
      BookingActionsNotifier.new,
    );
