import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/best_weekday_report.dart';
import '../repositories/report_repository.dart';

class GetBestWeekdayReport {
  GetBestWeekdayReport({required ReportRepository repository})
    : _repository = repository;

  final ReportRepository _repository;

  Future<Either<Failure, BestWeekdayReport?>> call(DateTime month) {
    return _repository.getBestWeekdayReport(month);
  }
}
