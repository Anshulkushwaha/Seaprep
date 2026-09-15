class SupabaseConfig {
  /// Supabase Project URL.
  /// Pass via `--dart-define=SUPABASE_URL=https://your-project.supabase.co`
  /// or update the defaultValue below.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cjornqgdcfopuntxnnxx.supabase.co',
  );

  /// Supabase Anon/Publishable Key.
  /// Pass via `--dart-define=SUPABASE_ANON_KEY=your_anon_key`
  /// or update the defaultValue below.
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_GLlAA9rAvNEIrnylF57pvA_at9ehQbK',
  );

  static bool get isConfigured =>
      url.isNotEmpty &&
      url != 'https://xyzcompany.supabase.co' &&
      anonKey.isNotEmpty;
}
