import '../models/suite.dart';

/// Suite repository contract — shared between Phase 2 (read) and Phase 3 (read + write).
///
/// Phase 2 uses only [getActiveSuites] and [getSuiteById].
/// Phase 3 additionally uses [updateSuite].
abstract interface class ISuiteRepository {
  /// Returns all suites with active = true (RLS enforced for regular users).
  Future<List<Suite>> getActiveSuites();

  /// Returns a single suite by id regardless of active flag (admin-accessible via RLS).
  Future<Suite> getSuiteById(String id);

  /// Updates suite metadata. Only callable by super_admin (RLS enforces this).
  Future<Suite> updateSuite(Suite suite);
}
