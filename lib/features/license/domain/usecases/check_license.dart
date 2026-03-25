import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/license.dart';
import '../repositories/license_repository.dart';

class CheckLicense {
  CheckLicense({required LicenseRepository repository})
    : _repository = repository;

  final LicenseRepository _repository;

  Future<Either<Failure, License>> call(String deviceId) {
    return _repository.getByDeviceId(deviceId);
  }
}
