import '../../../shared/models/booking.dart';
import '../../../shared/models/booking_type.dart';

/// Booking repository contract shared between Phase 2 (implementation)
/// and Phase 3 (read-only admin view via separate IAdminBookingRepository).
///
/// All methods operate in the context of the authenticated user (RLS enforced).
abstract interface class IBookingRepository {
  /// Returns all active bookings for the current user.
  Future<List<Booking>> getMyBookings();

  /// Returns dates that are fully unavailable for a given suite.
  /// A date is unavailable when all three BookingType slots are booked.
  Future<List<DateTime>> getUnavailableDates(String suiteId);

  /// Returns booked [BookingType]s for a specific suite and date,
  /// so the UI can show which slots are still available.
  Future<List<BookingType>> getBookedTypesForDate(String suiteId, DateTime date);

  /// Creates a booking. Throws if the slot is already taken (DB enforces uniqueness).
  Future<Booking> createBooking({
    required String suiteId,
    required DateTime date,
    required BookingType type,
  });

  /// Cancels (soft-deletes) a booking owned by the current user.
  Future<void> cancelBooking(String bookingId);
}
