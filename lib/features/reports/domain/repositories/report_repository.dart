import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/daily_report.dart';
import '../../../../domain/entities/monthly_report.dart';

abstract class ReportRepository {
  Future<Either<Failure, DailyReport>> getDailyReport(DateTime day);

  Future<Either<Failure, List<MonthlyReport>>> getMonthlyReports();
}
