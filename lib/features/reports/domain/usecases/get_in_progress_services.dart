import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/service_summary.dart';
import '../repositories/report_repository.dart';

class GetInProgressServices {
  GetInProgressServices({required ReportRepository repository})
    : _repository = repository;

  final ReportRepository _repository;

  Future<Either<Failure, List<ServiceSummary>>> call() {
    return _repository.getTodayServices(DateTime.now());
  }
}
