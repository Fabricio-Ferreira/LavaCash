import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/daily_report.dart';
import '../repositories/report_repository.dart';

class GetDailyReport {
  GetDailyReport({required ReportRepository repository})
    : _repository = repository;

  final ReportRepository _repository;

  Future<Either<Failure, DailyReport>> call(DateTime day) {
    return _repository.getDailyReport(day);
  }
}
