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
}
