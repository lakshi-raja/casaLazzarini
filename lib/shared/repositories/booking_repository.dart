import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exceptions.dart';
import '../models/booking.dart';
import '../models/booking_type.dart';
import '../../features/bookings/domain/i_booking_repository.dart';

class BookingRepository implements IBookingRepository {
  const BookingRepository(this._client);

  final SupabaseClient _client;

  // Used by admin (fetches all ACTIVE bookings regardless of owner).
  Future<List<Booking>> fetchActiveBookings({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      var query = _client.from('bookings').select().eq('status', 'ACTIVE');
      if (from != null) query = query.gte('booking_date', _fmt(from));
      if (to != null) query = query.lte('booking_date', _fmt(to));
      final data = await query.order('booking_date');
      return [for (final m in data) Booking.fromMap(m)];
    } on PostgrestException catch (e) {
      throw NetworkException(
        'Errore nel caricamento disponibilità: ${e.message}',
      );
    }
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthenticationException('Non autenticato.');
    try {
      final data = await _client
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('booking_date', ascending: false);
      return [for (final m in data) Booking.fromMap(m)];
    } on PostgrestException catch (e) {
      throw NetworkException(
        'Errore nel caricamento prenotazioni: ${e.message}',
      );
    }
  }

  @override
  Future<List<DateTime>> getUnavailableDates(String suiteId) async {
    try {
      final data = await _client
          .from('bookings')
          .select('booking_date, booking_type')
          .eq('suite_id', suiteId)
          .eq('status', 'ACTIVE');
      final byDate = <String, Set<String>>{};
      for (final m in data) {
        final d = m['booking_date'] as String;
        byDate.putIfAbsent(d, Set.new).add(m['booking_type'] as String);
      }
      final totalTypes = BookingType.values.length;
      return [
        for (final e in byDate.entries)
          if (e.value.length >= totalTypes) DateTime.parse(e.key),
      ];
    } on PostgrestException catch (e) {
      throw NetworkException(
        'Errore nel caricamento disponibilità: ${e.message}',
      );
    }
  }

  @override
  Future<List<BookingType>> getBookedTypesForDate(
    String suiteId,
    DateTime date,
  ) async {
    try {
      final data = await _client
          .from('bookings')
          .select('booking_type')
          .eq('suite_id', suiteId)
          .eq('booking_date', _fmt(date))
          .eq('status', 'ACTIVE');
      return [
        for (final m in data)
          BookingType.values.firstWhere(
            (t) => t.toDatabaseString() == m['booking_type'],
          ),
      ];
    } on PostgrestException catch (e) {
      throw NetworkException(
        'Errore nel caricamento prenotazioni: ${e.message}',
      );
    }
  }

  @override
  Future<Booking> createBooking({
    required String suiteId,
    required DateTime date,
    required BookingType type,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthenticationException('Non autenticato.');
    try {
      final data = await _client
          .from('bookings')
          .insert({
            'user_id': userId,
            'suite_id': suiteId,
            'booking_date': _fmt(date),
            'booking_type': type.toDatabaseString(),
            'status': 'ACTIVE',
          })
          .select()
          .single();
      return Booking.fromMap(data);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const BookingConflictException(
          'Questo slot è già prenotato. Scegli un\'altra data o tipologia.',
        );
      }
      throw NetworkException(
        'Errore nella creazione della prenotazione: ${e.message}',
      );
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _client
          .from('bookings')
          .update({'status': 'CANCELLED'})
          .eq('id', bookingId)
          .eq('status', 'ACTIVE');
    } on PostgrestException catch (e) {
      throw NetworkException('Errore nella cancellazione: ${e.message}');
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
