import 'package:casa_lazzarini/features/admin/domain/booking_filter.dart';
import 'package:casa_lazzarini/shared/models/booking_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingFilter', () {
    const empty = BookingFilter();

    test('default constructor produces empty filter', () {
      expect(empty.isEmpty, isTrue);
      expect(empty.status, isNull);
      expect(empty.suiteId, isNull);
      expect(empty.dateFrom, isNull);
      expect(empty.dateTo, isNull);
    });

    test('withStatus sets status and preserves other fields', () {
      final f = empty.withStatus(BookingStatus.active);
      expect(f.status, BookingStatus.active);
      expect(f.isEmpty, isFalse);
      expect(f.suiteId, isNull);
      expect(f.dateFrom, isNull);
    });

    test('withStatus(null) clears status', () {
      final f = empty.withStatus(BookingStatus.cancelled).withStatus(null);
      expect(f.status, isNull);
      expect(f.isEmpty, isTrue);
    });

    test('withSuiteId sets suiteId and preserves other fields', () {
      final f = empty.withStatus(BookingStatus.active).withSuiteId('suite-1');
      expect(f.suiteId, 'suite-1');
      expect(f.status, BookingStatus.active);
    });

    test('withSuiteId(null) clears suiteId', () {
      final f = empty.withSuiteId('suite-1').withSuiteId(null);
      expect(f.suiteId, isNull);
      expect(f.isEmpty, isTrue);
    });

    test('withDateRange sets both dates', () {
      final from = DateTime(2026, 10, 1);
      final to = DateTime(2026, 10, 31);
      final f = empty.withDateRange(from, to);
      expect(f.dateFrom, from);
      expect(f.dateTo, to);
      expect(f.isEmpty, isFalse);
    });

    test('withDateRange(null, null) clears dates', () {
      final f = empty
          .withDateRange(DateTime(2026, 10, 1), DateTime(2026, 10, 31))
          .withDateRange(null, null);
      expect(f.dateFrom, isNull);
      expect(f.dateTo, isNull);
      expect(f.isEmpty, isTrue);
    });

    test('isEmpty returns false when any field is set', () {
      expect(empty.withStatus(BookingStatus.active).isEmpty, isFalse);
      expect(empty.withSuiteId('x').isEmpty, isFalse);
      expect(empty.withDateRange(DateTime(2026), null).isEmpty, isFalse);
      expect(empty.withDateRange(null, DateTime(2026)).isEmpty, isFalse);
    });

    test('equality is structural', () {
      final a = const BookingFilter(status: BookingStatus.active);
      final b = const BookingFilter(status: BookingStatus.active);
      expect(a, equals(b));
    });

    test('different filters are not equal', () {
      final a = const BookingFilter(status: BookingStatus.active);
      final b = const BookingFilter(status: BookingStatus.cancelled);
      expect(a, isNot(equals(b)));
    });

    test('hashCode matches for equal filters', () {
      final a = const BookingFilter(status: BookingStatus.active, suiteId: 'x');
      final b = const BookingFilter(status: BookingStatus.active, suiteId: 'x');
      expect(a.hashCode, b.hashCode);
    });

    test('chaining multiple withX calls preserves all fields', () {
      final from = DateTime(2026, 10, 1);
      final to = DateTime(2026, 10, 31);
      final f = empty
          .withStatus(BookingStatus.cancelled)
          .withSuiteId('suite-2')
          .withDateRange(from, to);
      expect(f.status, BookingStatus.cancelled);
      expect(f.suiteId, 'suite-2');
      expect(f.dateFrom, from);
      expect(f.dateTo, to);
      expect(f.isEmpty, isFalse);
    });
  });
}
