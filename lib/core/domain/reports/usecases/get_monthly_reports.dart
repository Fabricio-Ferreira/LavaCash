import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/monthly_report.dart';
import '../repositories/report_repository.dart';

class GetMonthlyReports {
  GetMonthlyReports({required ReportRepository repository})
    : _repository = repository;

  final ReportRepository _repository;

  Future<Either<Failure, List<MonthlyReport>>> call() {
    return _repository.getMonthlyReports();
  }
}
