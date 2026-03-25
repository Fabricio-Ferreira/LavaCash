import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/weekly_report.dart';
import '../repositories/report_repository.dart';

class GetWeeklyReport {
  GetWeeklyReport({required ReportRepository repository})
      : _repository = repository;

  final ReportRepository _repository;

  Future<Either<Failure, List<WeeklyReport>>> call(DateTime month) {
    return _repository.getWeeklyReport(month);
  }
}
