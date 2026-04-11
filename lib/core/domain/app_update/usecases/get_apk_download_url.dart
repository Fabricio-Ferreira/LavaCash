import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/app_update_repository.dart';

class GetApkDownloadUrl {
  GetApkDownloadUrl({required AppUpdateRepository repository})
    : _repository = repository;

  final AppUpdateRepository _repository;

  Future<Either<Failure, String>> call() {
    return _repository.getApkDownloadUrl();
  }
}
