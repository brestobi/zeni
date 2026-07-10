import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase;

  NotificationService(this._supabase);

  Future<void> initialize() async {
    // Request permissions
    await _messaging.requestPermission();

    // Get FCM Token
    final token = await _messaging.getToken();
    if (token != null) {
      // Store token in Supabase
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase.from('device_tokens').upsert({
          'user_id': userId,
          'token': token,
        });
      }
    }
  }
}
