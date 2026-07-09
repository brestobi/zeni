import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton wrapper around the Supabase client.
///
/// Provides typed access to the Supabase instance
/// shared across the rider and driver applications.
class SupabaseClientWrapper {
  SupabaseClientWrapper._();

  static SupabaseClientWrapper? _instance;
  static SupabaseClientWrapper get instance {
    _instance ??= SupabaseClientWrapper._();
    return _instance!;
  }

  SupabaseClient get client {
    final client = Supabase.instance.client;
    return client;
  }

  /// Initialize Supabase with the provided [url] and [anonKey].
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
