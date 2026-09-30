import 'package:casa_lazzarini/core/errors/app_exceptions.dart';
import 'package:casa_lazzarini/shared/models/booking.dart';
import 'package:casa_lazzarini/shared/models/booking_status.dart';
import 'package:casa_lazzarini/shared/models/booking_type.dart';
import 'package:casa_lazzarini/shared/models/profile.dart';
import 'package:casa_lazzarini/shared/models/suite.dart';
import 'package:casa_lazzarini/shared/models/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── UserRole ──────────────────────────────────────────────────────────────
  group('UserRole', () {
    test('fromDatabase maps user correctly', () {
      expect(UserRoleX.fromDatabase('user'), UserRole.user);
    });

    test('fromDatabase maps super_admin correctly', () {
      expect(UserRoleX.fromDatabase('super_admin'), UserRole.superAdmin);
    });

    test('fromDatabase throws on unknown value', () {
      expect(
        () => UserRoleX.fromDatabase('admin'),
        throwsA(isA<AppException>()),
      );
    });

    test('toDatabaseString round-trips user', () {
      expect(UserRole.user.toDatabaseString(), 'user');
    });

    test('toDatabaseString round-trips super_admin', () {
      expect(UserRole.superAdmin.toDatabaseString(), 'super_admin');
    });
  });

  // ── BookingType ───────────────────────────────────────────────────────────
  group('BookingType', () {
    test('fromDatabase maps all three types', () {
      expect(
        BookingTypeX.fromDatabase('AFTERNOON_MORNING'),
        BookingType.afternoonMorning,
      );
      expect(
        BookingTypeX.fromDatabase('MORNING_NIGHT'),
        BookingType.morningNight,
      );
      expect(BookingTypeX.fromDatabase('NIGHT'), BookingType.night);
    });

    test('toDatabaseString round-trips', () {
      expect(
        BookingType.afternoonMorning.toDatabaseString(),
        'AFTERNOON_MORNING',
      );
      expect(BookingType.morningNight.toDatabaseString(), 'MORNING_NIGHT');
      expect(BookingType.night.toDatabaseString(), 'NIGHT');
    });

    test('italianLabel returns correct Italian strings', () {
      expect(BookingType.afternoonMorning.italianLabel, 'Pomeriggio – Mattina');
      expect(BookingType.morningNight.italianLabel, 'Mattina – Notte');
      expect(BookingType.night.italianLabel, 'Notte');
    });

    test('fromDatabase throws on unknown value', () {
      expect(
        () => BookingTypeX.fromDatabase('UNKNOWN'),
        throwsA(isA<AppException>()),
      );
    });
  });

  // ── BookingStatus ─────────────────────────────────────────────────────────
  group('BookingStatus', () {
    test('fromDatabase maps ACTIVE and CANCELLED', () {
      expect(BookingStatusX.fromDatabase('ACTIVE'), BookingStatus.active);
      expect(BookingStatusX.fromDatabase('CANCELLED'), BookingStatus.cancelled);
    });

    test('toDatabaseString round-trips', () {
      expect(BookingStatus.active.toDatabaseString(), 'ACTIVE');
      expect(BookingStatus.cancelled.toDatabaseString(), 'CANCELLED');
    });
  });

  // ── Profile ───────────────────────────────────────────────────────────────
  group('Profile', () {
    final map = {
      'id': 'uuid-123',
      'full_name': 'Mario Rossi',
      'role': 'user',
      'created_at': '2026-09-30T10:00:00.000Z',
      'updated_at': '2026-09-30T10:00:00.000Z',
    };

    test('fromMap parses correctly', () {
      final p = Profile.fromMap(map);
      expect(p.id, 'uuid-123');
      expect(p.fullName, 'Mario Rossi');
      expect(p.role, UserRole.user);
    });

    test('copyWith replaces only specified fields', () {
      final p = Profile.fromMap(map);
      final p2 = p.copyWith(fullName: 'Luigi Bianchi');
      expect(p2.fullName, 'Luigi Bianchi');
      expect(p2.id, p.id);
      expect(p2.role, p.role);
    });
  });

  // ── Suite ─────────────────────────────────────────────────────────────────
  group('Suite', () {
    final map = {
      'id': 'suite-uuid-1',
      'code': 'SUITE_1',
      'display_name': 'Suite n.1',
      'active': true,
      'created_at': '2026-09-30T10:00:00.000Z',
    };

    test('fromMap parses correctly', () {
      final s = Suite.fromMap(map);
      expect(s.code, 'SUITE_1');
      expect(s.displayName, 'Suite n.1');
      expect(s.active, true);
    });
  });

  // ── Booking ───────────────────────────────────────────────────────────────
  group('Booking', () {
    final map = {
      'id': 'booking-uuid-1',
      'user_id': 'user-uuid-1',
      'suite_id': 'suite-uuid-1',
      'booking_date': '2026-10-15',
      'booking_type': 'NIGHT',
      'status': 'ACTIVE',
      'created_at': '2026-09-30T10:00:00.000Z',
      'updated_at': '2026-09-30T10:00:00.000Z',
    };

    test('fromMap parses correctly', () {
      final b = Booking.fromMap(map);
      expect(b.bookingType, BookingType.night);
      expect(b.status, BookingStatus.active);
      expect(b.suiteId, 'suite-uuid-1');
    });

    test('bookingDate is normalised to midnight UTC', () {
      final b = Booking.fromMap(map);
      expect(b.bookingDate.hour, 0);
      expect(b.bookingDate.minute, 0);
      expect(b.bookingDate.isUtc, true);
    });

    test('copyWith replaces status only', () {
      final b = Booking.fromMap(map);
      final b2 = b.copyWith(status: BookingStatus.cancelled);
      expect(b2.status, BookingStatus.cancelled);
      expect(b2.id, b.id);
    });
  });

  // ── AppException hierarchy ────────────────────────────────────────────────
  group('AppException hierarchy', () {
    test('AuthenticationException is AppException', () {
      const e = AuthenticationException('bad creds');
      expect(e, isA<AppException>());
      expect(e.message, 'bad creds');
    });

    test('BookingConflictException is AppException', () {
      const e = BookingConflictException('slot taken');
      expect(e, isA<AppException>());
    });
  });
}
