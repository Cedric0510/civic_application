import 'package:civic_app/features/services/data/models/service_model.dart';
import 'package:civic_app/features/services/domain/entities/service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceSupabaseDatasource {
  const ServiceSupabaseDatasource(this._client);

  final SupabaseClient _client;

  Future<List<Service>> getServices() async {
    final response = await _client
        .from('services')
        .select()
        .order('category', ascending: true)
        .order('name', ascending: true);
    return (response as List)
        .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
