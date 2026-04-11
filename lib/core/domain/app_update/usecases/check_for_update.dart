import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/update_check_result.dart';
import '../repositories/app_update_repository.dart';

class CheckForUpdate {
  CheckForUpdate({required AppUpdateRepository repository})
    : _repository = repository;

  final AppUpdateRepository _repository;

  Future<Either<Failure, UpdateCheckResult>> call() {
    return _repository.checkForUpdate();
  }
}
