import 'package:flutter/foundation.dart';
import 'package:casa_lazzarini/shared/models/booking_status.dart';

@immutable
class BookingFilter {
  final BookingStatus? status;
  final String? suiteId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const BookingFilter({this.status, this.suiteId, this.dateFrom, this.dateTo});

  BookingFilter withStatus(BookingStatus? status) => BookingFilter(
    status: status,
    suiteId: suiteId,
    dateFrom: dateFrom,
    dateTo: dateTo,
  );

  BookingFilter withSuiteId(String? suiteId) => BookingFilter(
    status: status,
    suiteId: suiteId,
    dateFrom: dateFrom,
    dateTo: dateTo,
  );

  BookingFilter withDateRange(DateTime? from, DateTime? to) => BookingFilter(
    status: status,
    suiteId: suiteId,
    dateFrom: from,
    dateTo: to,
  );

  bool get isEmpty =>
      status == null && suiteId == null && dateFrom == null && dateTo == null;

  @override
  bool operator ==(Object other) =>
      other is BookingFilter &&
      other.status == status &&
      other.suiteId == suiteId &&
      other.dateFrom == dateFrom &&
      other.dateTo == dateTo;

  @override
  int get hashCode => Object.hash(status, suiteId, dateFrom, dateTo);
}
