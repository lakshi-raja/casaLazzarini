import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exceptions.dart';
import '../models/suite.dart';
import 'i_suite_repository.dart';

class SuiteRepository implements ISuiteRepository {
  const SuiteRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Suite>> getActiveSuites() async {
    try {
      final data = await _client
          .from('suites')
          .select()
          .eq('active', true)
          .order('code');
      return [for (final m in data) Suite.fromMap(m)];
    } on PostgrestException catch (e) {
      throw NetworkException('Errore nel caricamento suite: ${e.message}');
    }
  }

  @override
  Future<Suite> getSuiteById(String id) async {
    try {
      final data = await _client.from('suites').select().eq('id', id).single();
      return Suite.fromMap(data);
    } on PostgrestException catch (e) {
      throw NetworkException('Errore nel caricamento suite: ${e.message}');
    }
  }

  @override
  Future<Suite> updateSuite(Suite suite) async {
    try {
      final data = await _client
          .from('suites')
          .update({'display_name': suite.displayName, 'active': suite.active})
          .eq('id', suite.id)
          .select()
          .single();
      return Suite.fromMap(data);
    } on PostgrestException catch (e) {
      throw NetworkException('Errore nell\'aggiornamento suite: ${e.message}');
    }
  }
}
