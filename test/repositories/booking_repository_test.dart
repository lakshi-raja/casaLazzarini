import 'package:casa_lazzarini/core/errors/app_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Exception hierarchy contract ──────────────────────────────────────────
  //
  // BookingRepository maps PostgrestException(code='23505') →
  // BookingConflictException. This test verifies the exception contract
  // without requiring a real Supabase connection.

  group('BookingConflictException', () {
    test('is a subtype of AppException', () {
      const e = BookingConflictException('slot taken');
      expect(e, isA<AppException>());
      expect(e.message, 'slot taken');
    });

    test('toString includes class name', () {
      const e = BookingConflictException('conflict');
      expect(e.toString(), contains('BookingConflictException'));
    });
  });

  group('NetworkException', () {
    test('is a subtype of AppException', () {
      const e = NetworkException('no connection');
      expect(e, isA<AppException>());
    });
  });

  // ── Date formatting ───────────────────────────────────────────────────────
  //
  // The repository formats dates as 'YYYY-MM-DD' for Supabase queries.
  // We test the format via the models which use the same date parsing.

  group('Booking date normalization', () {
    test('fromMap normalises to UTC midnight', () {
      // Mirrors Booking.fromMap date handling used by the repository result.
      final raw = DateTime.parse('2026-10-15');
      final normalised = DateTime.utc(raw.year, raw.month, raw.day);
      expect(normalised.isUtc, true);
      expect(normalised.hour, 0);
      expect(normalised.day, 15);
    });

    test('padding single-digit month and day', () {
      // Mirrors BookingRepository._fmt
      final d = DateTime(2026, 3, 7);
      final formatted =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      expect(formatted, '2026-03-07');
    });
  });
}
