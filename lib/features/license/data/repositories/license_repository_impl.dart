import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../data/models/license_model.dart';
import '../../../../domain/entities/license.dart';
import '../../domain/repositories/license_repository.dart';

class LicenseRepositoryImpl implements LicenseRepository {
  LicenseRepositoryImpl({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  @override
  Future<Either<Failure, License>> getByDeviceId(String deviceId) async {
    if (_client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final Map<String, dynamic>? row =
          await _client
              .from('licencas')
              .select()
              .eq('device_id', deviceId)
              .maybeSingle();
      if (row == null) {
        return const Left(LicenseFailure('No license for this device'));
      }
      final LicenseModel model = LicenseModel.fromJson(row);
      if (!model.isActive) {
        return const Left(LicenseFailure('License inactive'));
      }
      return Right(model.toDomain());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, License>> activateWithKey({
    required String deviceId,
    required String activationKey,
  }) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Left(ServerFailure('Supabase not configured'));
    }
    try {
      final dynamic response = await client.rpc(
        'activate_license',
        params: <String, dynamic>{
          'p_device_id': deviceId,
          'p_activation_key': activationKey,
        },
      );
      final Map<String, dynamic>? row = _parseActivateLicenseRow(response);
      if (row == null) {
        return const Left(LicenseFailure('Activation failed'));
      }
      final LicenseModel model = LicenseModel.fromJson(row);
      return Right(model.toDomain());
    } on PostgrestException catch (e) {
      return Left(LicenseFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Map<String, dynamic>? _parseActivateLicenseRow(dynamic response) {
    if (response == null) {
      return null;
    }
    if (response is List<dynamic>) {
      if (response.isEmpty) {
        return null;
      }
      final Object? first = response.first;
      if (first is Map<String, dynamic>) {
        return first;
      }
      return null;
    }
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }
}
