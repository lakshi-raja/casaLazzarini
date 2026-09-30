import 'package:casa_lazzarini/core/errors/app_exceptions.dart';

enum BookingStatus { active, cancelled }

extension BookingStatusX on BookingStatus {
  static BookingStatus fromDatabase(String value) {
    switch (value) {
      case 'ACTIVE':
        return BookingStatus.active;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      default:
        throw AppException('Unknown BookingStatus database value: "$value"');
    }
  }

  String toDatabaseString() {
    switch (this) {
      case BookingStatus.active:
        return 'ACTIVE';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }
}
