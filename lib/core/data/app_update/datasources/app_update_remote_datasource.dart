import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../models/update_info_model.dart';

class AppUpdateRemoteDataSource {
  AppUpdateRemoteDataSource({required SupabaseClient? client})
    : _client = client;

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

  Future<String> getApkSignedUrl() async {
    final SupabaseClient? client = _client;
    if (client == null) {
      throw UpdateFailure('Supabase is not configured');
    }
    try {
      final FunctionResponse response = await client.functions.invoke(
        'download-apk',
      );
      final dynamic data = response.data;
      final Map<String, dynamic> map =
          data is Map<String, dynamic>
              ? data
              : Map<String, dynamic>.from(data as Map<dynamic, dynamic>);
      final Object? url = map['url'];
      if (url is String && url.isNotEmpty) {
        return url;
      }
      final Object? err = map['error'];
      throw UpdateFailure(
        err is String && err.isNotEmpty ? err : 'Missing signed URL',
      );
    } on UpdateFailure {
      rethrow;
    } on FunctionException catch (e) {
      final Object? details = e.details;
      if (details is Map<dynamic, dynamic> && details['error'] != null) {
        throw UpdateFailure(details['error'].toString());
      }
      throw UpdateFailure(e.reasonPhrase ?? e.toString());
    } on Exception catch (e) {
      throw UpdateFailure(e.toString());
    }
  }
}
