import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exceptions.dart';
import '../models/suite.dart';

class SuiteRepository {
  const SuiteRepository(this._client);

  final SupabaseClient _client;

  Future<List<Suite>> fetchActive() async {
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
}
