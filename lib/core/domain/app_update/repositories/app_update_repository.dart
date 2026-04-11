import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/update_check_result.dart';

abstract class AppUpdateRepository {
  Future<Either<Failure, UpdateCheckResult>> checkForUpdate();

  Future<Either<Failure, String>> getApkDownloadUrl();
}
