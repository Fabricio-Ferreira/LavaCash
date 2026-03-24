import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/daily_report.dart';
import '../../../../domain/entities/monthly_report.dart';
import '../../domain/usecases/get_daily_report.dart';
import '../../domain/usecases/get_monthly_reports.dart';

class ReportController extends GetxController {
  ReportController({
    required GetDailyReport getDailyReport,
    required GetMonthlyReports getMonthlyReports,
  })  : _getDailyReport = getDailyReport,
        _getMonthlyReports = getMonthlyReports;

  final GetDailyReport _getDailyReport;
  final GetMonthlyReports _getMonthlyReports;

  final RxBool isDailyLoading = false.obs;
  final RxBool isMonthlyLoading = false.obs;
  final Rxn<DailyReport> dailyReport = Rxn<DailyReport>();
  final RxList<MonthlyReport> monthlyReports = <MonthlyReport>[].obs;
  final RxString errorMessage = ''.obs;

  Future<void> loadDaily() async {
    isDailyLoading.value = true;
    final Either<Failure, DailyReport> result =
        await _getDailyReport(DateTime.now());
    result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        dailyReport.value = null;
      },
      (DailyReport report) {
        errorMessage.value = '';
        dailyReport.value = report;
      },
    );
    isDailyLoading.value = false;
  }

  Future<void> loadMonthly() async {
    isMonthlyLoading.value = true;
    final Either<Failure, List<MonthlyReport>> result =
        await _getMonthlyReports();
    result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        monthlyReports.clear();
      },
      (List<MonthlyReport> list) {
        errorMessage.value = '';
        monthlyReports.assignAll(list);
      },
    );
    isMonthlyLoading.value = false;
  }
}
