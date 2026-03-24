import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/license.dart';

abstract class LicenseRepository {
  Future<Either<Failure, License>> getByDeviceId(String deviceId);
}
