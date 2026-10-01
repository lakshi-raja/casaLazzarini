import '../../../shared/models/booking.dart';
import '../../../shared/models/booking_type.dart';

enum DateAvailability { available, partial, unavailable }

/// Returns aggregate availability for [date] across all suites.
///
/// [suiteCount] is the total number of active suites (max slots = suiteCount × 3 types).
DateAvailability computeDateAvailability(
  List<Booking> activeBookings,
  DateTime date,
  int suiteCount,
) {
  if (suiteCount == 0) return DateAvailability.unavailable;
  final count = activeBookings
      .where((b) => _sameDay(b.bookingDate, date))
      .length;
  if (count == 0) return DateAvailability.available;
  final total = suiteCount * BookingType.values.length;
  if (count >= total) return DateAvailability.unavailable;
  return DateAvailability.partial;
}

/// Returns a map of BookingType → isAvailable for a specific suite on [date].
Map<BookingType, bool> computeSuiteTypeAvailability(
  List<Booking> activeBookings,
  DateTime date,
  String suiteId,
) {
  final taken = activeBookings
      .where((b) => b.suiteId == suiteId && _sameDay(b.bookingDate, date))
      .map((b) => b.bookingType)
      .toSet();
  return {for (final t in BookingType.values) t: !taken.contains(t)};
}

/// Collapses per-type availability into a single state for one suite on [date].
DateAvailability computeSuiteAvailability(
  List<Booking> activeBookings,
  DateTime date,
  String suiteId,
) {
  final typeAvail = computeSuiteTypeAvailability(activeBookings, date, suiteId);
  final freeCount = typeAvail.values.where((v) => v).length;
  if (freeCount == 0) return DateAvailability.unavailable;
  if (freeCount == typeAvail.length) return DateAvailability.available;
  return DateAvailability.partial;
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
