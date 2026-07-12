import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';

abstract class AuthRepository {
  Future<void> signInWithOtp({required String phone});
  Future<AuthResponse> verifyOTP({
    required String phone,
    required String token,
  });
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  });
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  });
  Future<AuthResponse> signInWithGoogle({
    required String idToken,
    String? accessToken,
  });
  Future<Profile> getOrCreateProfile(String userId, String identifier);
  Future<Driver?> getDriver(String userId);
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  Future<void> signInWithOtp({required String phone}) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  @override
  Future<AuthResponse> verifyOTP({
    required String phone,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      type: OtpType.sms,
      token: token,
      phone: phone,
    );
  }

  @override
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signInWithGoogle({
    required String idToken,
    String? accessToken,
  }) async {
    return await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Future<Profile> getOrCreateProfile(String userId, String phoneNumber) async {
    // Try to fetch existing profile
    final existing = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (existing != null) {
      return Profile.fromJson(existing);
    }

    // Create new profile if it doesn't exist
    final now = DateTime.now().toIso8601String();
    final newProfile = {
      'id': userId,
      'phone_number': phoneNumber,
      'created_at': now,
      'updated_at': now,
    };

    await _client.from('profiles').insert(newProfile);
    return Profile.fromJson(newProfile);
  }

  @override
  Future<Driver?> getDriver(String userId) async {
    final data = await _client.from('drivers').select().eq('id', userId).maybeSingle();
    if (data == null) return null;
    return Driver.fromJson(data);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
