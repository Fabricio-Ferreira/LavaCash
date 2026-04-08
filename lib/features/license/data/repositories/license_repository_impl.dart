import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/license_encrypted_local_cache.dart';
import '../../../../data/models/license_model.dart';
import '../../../../domain/entities/license.dart';
import '../license_rpc_error_mapper.dart';
import '../../domain/repositories/license_repository.dart';

class LicenseRepositoryImpl implements LicenseRepository {
  LicenseRepositoryImpl({
    required SupabaseClient client,
    required LicenseEncryptedLocalCache localCache,
  }) : _client = client,
       _localCache = localCache;

  final SupabaseClient _client;
  final LicenseEncryptedLocalCache _localCache;

  @override
  Future<Either<Failure, License>> getByDeviceId(String deviceId) async {
    final Map<String, dynamic>? cached = await _localCache.readLicenseRow();
    try {
      if (cached == null) {
        return const Left(LicenseFailure('No license for this device'));
      }
      final LicenseModel model = LicenseModel.fromJson(cached);
      final String activationCode = model.activationCode ?? '';
      if (activationCode.isEmpty) {
        return const Left(LicenseFailure('No license for this device'));
      }
      final dynamic response = await _client.rpc(
        'find_license_by_activate_code',
        params: <String, dynamic>{
          'p_activate_code': activationCode,
          'p_device_id': deviceId,
        },
      );
      final Map<String, dynamic>? row = _parseRpcRow(response);
      if (row == null) {
        return const Left(LicenseFailure('No license for this device'));
      }
      final LicenseModel licenseModel = LicenseModel.fromJson(row);
      if (!licenseModel.isActive) {
        return const Left(LicenseFailure('License inactive'));
      }
      return Right(licenseModel.toDomain());
    } on PostgrestException catch (e) {
      return Left(LicenseFailure(mapLicensePostgrestMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, License>> activateWithKey({
    required String deviceId,
    required String activationKey,
  }) async {
    final String trimmed = activationKey.trim();
    try {
      final dynamic response = await _client.rpc(
        'find_license_by_activate_code',
        params: <String, dynamic>{
          'p_activate_code': trimmed,
          'p_device_id': deviceId,
        },
      );
      final Map<String, dynamic>? row = _parseRpcRow(response);
      if (row == null) {
        return const Left(LicenseFailure('Activation failed'));
      }
      final LicenseModel model = LicenseModel.fromJson(row);
      if (!model.isActive) {
        return const Left(LicenseFailure('License inactive'));
      }
      await _localCache.saveLicenseRow(row);
      return Right(model.toDomain());
    } on PostgrestException catch (e) {
      return Left(LicenseFailure(mapLicensePostgrestMessage(e)));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Map<String, dynamic>? _parseRpcRow(dynamic response) {
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
