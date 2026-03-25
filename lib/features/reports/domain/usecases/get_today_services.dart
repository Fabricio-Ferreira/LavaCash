import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/service_summary.dart';
import '../repositories/report_repository.dart';

class GetTodayServices {
  GetTodayServices({required ReportRepository repository})
    : _repository = repository;

  final ReportRepository _repository;

  Future<Either<Failure, List<ServiceSummary>>> call(
    DateTime day, {
    int? limit,
  }) {
    return _repository.getTodayServices(day, limit: limit);
  }
}
