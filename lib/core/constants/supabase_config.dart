/// Supabase client-safe configuration.
///
/// Supply values via environment or a local `supabase_config.local.dart`
/// (git-ignored). Never commit real credentials here.
///
/// To configure:
/// 1. Copy this pattern to a local override (see README for details).
/// 2. Replace the placeholder strings with your Supabase Project URL
///    and anon/publishable key from the Supabase dashboard.
///
/// The anon key is intentionally client-safe — it respects Row Level Security.
/// NEVER place the service-role key in the Flutter app.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static bool get isConfigured =>
      url != 'YOUR_SUPABASE_URL' && anonKey != 'YOUR_SUPABASE_ANON_KEY';
}
