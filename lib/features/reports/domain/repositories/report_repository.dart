import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/best_weekday_report.dart';
import '../../../../domain/entities/daily_report.dart';
import '../../../../domain/entities/monthly_report.dart';
import '../../../../domain/entities/service_summary.dart';
import '../../../../domain/entities/weekly_report.dart';

abstract class ReportRepository {
  Future<Either<Failure, DailyReport>> getDailyReport(DateTime day);

  Future<Either<Failure, List<ServiceSummary>>> getTodayServices(
    DateTime day, {
    int? limit,
  });

  Future<Either<Failure, List<MonthlyReport>>> getMonthlyReports();

  Future<Either<Failure, List<WeeklyReport>>> getWeeklyReport(DateTime month);

  Future<Either<Failure, BestWeekdayReport?>> getBestWeekdayReport(
    DateTime month,
  );
}
