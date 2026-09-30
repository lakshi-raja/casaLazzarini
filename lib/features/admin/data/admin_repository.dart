import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:casa_lazzarini/core/errors/app_exceptions.dart';
import 'package:casa_lazzarini/shared/models/booking.dart';
import 'package:casa_lazzarini/shared/models/booking_status.dart';
import 'package:casa_lazzarini/shared/models/profile.dart';
import 'package:casa_lazzarini/shared/models/suite.dart';

import '../domain/booking_filter.dart';

class AdminRepository {
  AdminRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<List<Booking>> fetchBookings({BookingFilter? filter}) async {
    try {
      var q = _client.from('bookings').select();
      if (filter?.status != null) {
        q = q.eq('status', filter!.status!.toDatabaseString());
      }
      if (filter?.suiteId != null) {
        q = q.eq('suite_id', filter!.suiteId!);
      }
      if (filter?.dateFrom != null) {
        q = q.gte('booking_date', _dateStr(filter!.dateFrom!));
      }
      if (filter?.dateTo != null) {
        q = q.lte('booking_date', _dateStr(filter!.dateTo!));
      }
      final data = await q.order('booking_date', ascending: false);
      return data.map(Booking.fromMap).toList();
    } on PostgrestException catch (e) {
      throw UnexpectedException(e.message);
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _client
          .from('bookings')
          .update({
            'status': 'CANCELLED',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', bookingId);
    } on PostgrestException catch (e) {
      throw UnexpectedException(e.message);
    }
  }

  Future<List<Suite>> fetchSuites() async {
    try {
      final data = await _client.from('suites').select().order('code');
      return data.map(Suite.fromMap).toList();
    } on PostgrestException catch (e) {
      throw UnexpectedException(e.message);
    }
  }

  Future<void> updateSuiteActive(String suiteId, {required bool active}) async {
    try {
      await _client.from('suites').update({'active': active}).eq('id', suiteId);
    } on PostgrestException catch (e) {
      throw UnexpectedException(e.message);
    }
  }

  Future<List<Profile>> fetchProfiles() async {
    try {
      final data = await _client.from('profiles').select().order('created_at');
      return data.map(Profile.fromMap).toList();
    } on PostgrestException catch (e) {
      throw UnexpectedException(e.message);
    }
  }
}
