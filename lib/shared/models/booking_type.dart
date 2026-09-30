import 'package:casa_lazzarini/core/errors/app_exceptions.dart';

enum BookingType { afternoonMorning, morningNight, night }

extension BookingTypeX on BookingType {
  static BookingType fromDatabase(String value) {
    switch (value) {
      case 'AFTERNOON_MORNING':
        return BookingType.afternoonMorning;
      case 'MORNING_NIGHT':
        return BookingType.morningNight;
      case 'NIGHT':
        return BookingType.night;
      default:
        throw AppException('Unknown BookingType database value: "$value"');
    }
  }

  String toDatabaseString() {
    switch (this) {
      case BookingType.afternoonMorning:
        return 'AFTERNOON_MORNING';
      case BookingType.morningNight:
        return 'MORNING_NIGHT';
      case BookingType.night:
        return 'NIGHT';
    }
  }

  String get italianLabel {
    switch (this) {
      case BookingType.afternoonMorning:
        return 'Pomeriggio – Mattina';
      case BookingType.morningNight:
        return 'Mattina – Notte';
      case BookingType.night:
        return 'Notte';
    }
  }
}
