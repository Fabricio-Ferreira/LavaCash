import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/best_weekday_report.dart';
import 'package:lava_cash/core/domain/entities/daily_report.dart';
import 'package:lava_cash/core/domain/entities/monthly_report.dart';
import 'package:lava_cash/core/domain/entities/service_summary.dart';
import 'package:lava_cash/core/domain/entities/weekly_report.dart';

abstract class ReportRepository {
  Future<Either<Failure, DailyReport>> getDailyReport(DateTime day);

  Future<Either<Failure, List<ServiceSummary>>> getTodayServices(
    DateTime day, {
    int? limit,
  });

  // Future<Either<Failure, List<ServiceSummary>>> getInProgressServices();

  Future<Either<Failure, List<MonthlyReport>>> getMonthlyReports();

  Future<Either<Failure, List<WeeklyReport>>> getWeeklyReport(DateTime month);

  Future<Either<Failure, BestWeekdayReport?>> getBestWeekdayReport(
    DateTime month,
  );

  /// Consolidated row for [vw_relatorio_diario_pdf] (PDF / export).
  Future<Either<Failure, Map<String, dynamic>>> getPdfDailySummary(
    DateTime day,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>>
  getPdfDailyAttendanceRows(DateTime day);

  Future<Either<Failure, List<Map<String, dynamic>>>> getPdfDailyExpenseRows(
    DateTime day,
  );

  /// Consolidated row for [vw_relatorio_mensal_pdf].
  Future<Either<Failure, Map<String, dynamic>>> getPdfMonthlySummary(
    DateTime month,
  );

  /// Inclusive [startInclusive] / [endInclusive] (local calendar days).
  /// Aggregates finalizados + despesas; max span enforced in implementation.
  Future<Either<Failure, Map<String, dynamic>>> getIntervalSummary(
    DateTime startInclusive,
    DateTime endInclusive,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>>
  getIntervalAttendanceRows(
    DateTime startInclusive,
    DateTime endInclusive,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> getIntervalExpenseRows(
    DateTime startInclusive,
    DateTime endInclusive,
  );
}
