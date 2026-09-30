import 'package:flutter/foundation.dart';
import 'package:casa_lazzarini/shared/models/booking_type.dart';
import 'package:casa_lazzarini/shared/models/booking_status.dart';

@immutable
class Booking {
  final String id;
  final String userId;
  final String suiteId;
  final DateTime bookingDate;
  final BookingType bookingType;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.suiteId,
    required this.bookingDate,
    required this.bookingType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    final rawDate = DateTime.parse(map['booking_date'] as String);
    final bookingDate = DateTime.utc(rawDate.year, rawDate.month, rawDate.day);

    return Booking(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      suiteId: map['suite_id'] as String,
      bookingDate: bookingDate,
      bookingType: BookingTypeX.fromDatabase(map['booking_type'] as String),
      status: BookingStatusX.fromDatabase(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? suiteId,
    DateTime? bookingDate,
    BookingType? bookingType,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      suiteId: suiteId ?? this.suiteId,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingType: bookingType ?? this.bookingType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
