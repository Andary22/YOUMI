class SupabaseConfig {
  static const String url = 'https://aydpelzfvkngucudhioy.supabase.co';
  static const String anonKey =
      'sb_publishable_DXLnZ5niLxnPUF21kgAxNQ_qDRIH7dP';

  static String get authBaseUrl {
    return '$url/auth/v1';
  }

  static String get restBaseUrl {
    return '$url/rest/v1';
  }
}
