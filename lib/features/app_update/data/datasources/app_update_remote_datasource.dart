import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../models/update_info_model.dart';

class AppUpdateRemoteDataSource {
  AppUpdateRemoteDataSource({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  Future<UpdateInfoModel> fetchLatestVersion() async {
    final SupabaseClient? client = _client;
    if (client == null) {
      throw UpdateFailure('Supabase is not configured');
    }
    try {
      final Object raw = await client.from('app_version').select().single();
      final Map<String, dynamic> row = Map<String, dynamic>.from(
        raw as Map<dynamic, dynamic>,
      );
      return UpdateInfoModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw UpdateFailure(e.message);
    } on Exception catch (e) {
      throw UpdateFailure(e.toString());
    }
  }
}
