import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zeni_models/zeni_models.dart';

class HistoryRepository {
  final SupabaseClient _supabase;

  HistoryRepository(this._supabase);

  Future<List<Ride>> getRideHistory(String userId, {bool isDriver = true}) async {
    final column = isDriver ? 'driver_id' : 'passenger_id';
    final data = await _supabase
        .from('rides')
        .select()
        .eq(column, userId)
        .eq('status', 'completed')
        .order('completed_at', ascending: false);

    return data.map((json) => Ride.fromJson(json)).toList();
  }
}
