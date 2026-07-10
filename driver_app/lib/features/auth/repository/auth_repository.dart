import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';

abstract class AuthRepository {
  Future<void> signInWithOtp({required String phone});
  Future<AuthResponse> verifyOTP({
    required String phone,
    required String token,
  });
  Future<Profile> getProfile(String userId);
  Future<Driver?> getDriver(String userId);
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
  Future<Profile> getProfile(String userId) async {
    final data = await _client.from('profiles').select().eq('id', userId).single();
    return Profile.fromJson(data);
  }

  @override
  Future<Driver?> getDriver(String userId) async {
    final data = await _client.from('drivers').select().eq('id', userId).maybeSingle();
    if (data == null) return null;
    return Driver.fromJson(data);
  }
}
