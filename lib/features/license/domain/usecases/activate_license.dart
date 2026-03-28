import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/license.dart';
import '../repositories/license_repository.dart';

class ActivateLicense {
  ActivateLicense({required LicenseRepository repository})
    : _repository = repository;

  final LicenseRepository _repository;

  Future<Either<Failure, License>> call({
    required String deviceId,
    required String activationKey,
  }) {
    return _repository.activateWithKey(
      deviceId: deviceId,
      activationKey: activationKey,
    );
  }
}
