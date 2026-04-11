import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/license.dart';

abstract class LicenseRepository {
  Future<Either<Failure, License>> getByDeviceId(String deviceId);

  Future<Either<Failure, License>> activateWithKey({
    required String deviceId,
    required String activationKey,
  });
}
