import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/report_repository.dart';

class GetIntervalReport {
  GetIntervalReport({required ReportRepository repository})
    : _repository = repository;

  final ReportRepository _repository;

  Future<Either<Failure, Map<String, dynamic>>> call(
    DateTime startInclusive,
    DateTime endInclusive,
  ) {
    return _repository.getIntervalSummary(startInclusive, endInclusive);
  }
}
