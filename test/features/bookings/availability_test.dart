import 'package:casa_lazzarini/features/bookings/domain/availability.dart';
import 'package:casa_lazzarini/shared/models/booking.dart';
import 'package:casa_lazzarini/shared/models/booking_status.dart';
import 'package:casa_lazzarini/shared/models/booking_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final date = DateTime.utc(2026, 10, 15);
  const suiteA = 'suite-a';
  const suiteB = 'suite-b';

  Booking makeBooking({
    required String suiteId,
    required BookingType type,
    DateTime? bookingDate,
  }) => Booking(
    id: 'id',
    userId: 'user',
    suiteId: suiteId,
    bookingDate: bookingDate ?? date,
    bookingType: type,
    status: BookingStatus.active,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  // ── computeDateAvailability ────────────────────────────────────────────────

  group('computeDateAvailability', () {
    test('returns available when no bookings exist for date', () {
      expect(computeDateAvailability([], date, 2), DateAvailability.available);
    });

    test('returns partial when some slots are taken', () {
      final bookings = [makeBooking(suiteId: suiteA, type: BookingType.night)];
      // 1 taken out of 6 (2 suites × 3 types)
      expect(
        computeDateAvailability(bookings, date, 2),
        DateAvailability.partial,
      );
    });

    test('returns unavailable when all slots are taken', () {
      final bookings = [
        for (final s in [suiteA, suiteB])
          for (final t in BookingType.values) makeBooking(suiteId: s, type: t),
      ];
      // 6 taken == 2 × 3 = fully booked
      expect(
        computeDateAvailability(bookings, date, 2),
        DateAvailability.unavailable,
      );
    });

    test('ignores bookings on a different date', () {
      final otherDate = DateTime.utc(2026, 10, 16);
      final bookings = [
        makeBooking(
          suiteId: suiteA,
          type: BookingType.night,
          bookingDate: otherDate,
        ),
      ];
      expect(
        computeDateAvailability(bookings, date, 2),
        DateAvailability.available,
      );
    });

    test('returns unavailable when suiteCount is 0', () {
      expect(
        computeDateAvailability([], date, 0),
        DateAvailability.unavailable,
      );
    });
  });

  // ── computeSuiteAvailability ──────────────────────────────────────────────

  group('computeSuiteAvailability', () {
    test('returns available when no bookings for suite', () {
      expect(
        computeSuiteAvailability([], date, suiteA),
        DateAvailability.available,
      );
    });

    test('returns partial when at least one type is taken but not all', () {
      final bookings = [makeBooking(suiteId: suiteA, type: BookingType.night)];
      expect(
        computeSuiteAvailability(bookings, date, suiteA),
        DateAvailability.partial,
      );
    });

    test('returns unavailable when all types are taken', () {
      final bookings = [
        for (final t in BookingType.values)
          makeBooking(suiteId: suiteA, type: t),
      ];
      expect(
        computeSuiteAvailability(bookings, date, suiteA),
        DateAvailability.unavailable,
      );
    });

    test('ignores bookings for a different suite', () {
      final bookings = [
        for (final t in BookingType.values)
          makeBooking(suiteId: suiteB, type: t),
      ];
      expect(
        computeSuiteAvailability(bookings, date, suiteA),
        DateAvailability.available,
      );
    });

    test('ignores bookings on a different date', () {
      final other = DateTime.utc(2026, 10, 16);
      final bookings = [
        for (final t in BookingType.values)
          makeBooking(suiteId: suiteA, type: t, bookingDate: other),
      ];
      expect(
        computeSuiteAvailability(bookings, date, suiteA),
        DateAvailability.available,
      );
    });
  });

  // ── computeSuiteTypeAvailability ──────────────────────────────────────────

  group('computeSuiteTypeAvailability', () {
    test('all types available when no bookings for that suite', () {
      final availability = computeSuiteTypeAvailability([], date, suiteA);
      expect(availability[BookingType.afternoonMorning], true);
      expect(availability[BookingType.morningNight], true);
      expect(availability[BookingType.night], true);
    });

    test('marks taken type as unavailable', () {
      final bookings = [makeBooking(suiteId: suiteA, type: BookingType.night)];
      final availability = computeSuiteTypeAvailability(bookings, date, suiteA);
      expect(availability[BookingType.night], false);
      expect(availability[BookingType.afternoonMorning], true);
      expect(availability[BookingType.morningNight], true);
    });

    test('bookings for other suite do not affect availability', () {
      final bookings = [makeBooking(suiteId: suiteB, type: BookingType.night)];
      final availability = computeSuiteTypeAvailability(bookings, date, suiteA);
      expect(availability[BookingType.night], true);
    });

    test('all types unavailable when fully booked', () {
      final bookings = [
        for (final t in BookingType.values)
          makeBooking(suiteId: suiteA, type: t),
      ];
      final availability = computeSuiteTypeAvailability(bookings, date, suiteA);
      for (final t in BookingType.values) {
        expect(
          availability[t],
          false,
          reason: '${t.name} should be unavailable',
        );
      }
    });
  });
}
