import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/best_weekday_report.dart';
import '../../../../domain/entities/daily_report.dart';
import '../../../../domain/entities/monthly_report.dart';
import '../../../../domain/entities/service_summary.dart';
import '../../../../domain/entities/weekly_report.dart';
import '../../domain/usecases/get_best_weekday_report.dart';
import '../../domain/usecases/get_daily_report.dart';
import '../../domain/usecases/get_monthly_reports.dart';
import '../../domain/usecases/get_today_services.dart';
import '../../domain/usecases/get_weekly_report.dart';

class ReportController extends GetxController {
  ReportController({
    required GetDailyReport getDailyReport,
    required GetTodayServices getTodayServices,
    required GetMonthlyReports getMonthlyReports,
    required GetWeeklyReport getWeeklyReport,
    required GetBestWeekdayReport getBestWeekdayReport,
  }) : _getDailyReport = getDailyReport,
       _getTodayServices = getTodayServices,
       _getMonthlyReports = getMonthlyReports,
       _getWeeklyReport = getWeeklyReport,
       _getBestWeekdayReport = getBestWeekdayReport;

  final GetDailyReport _getDailyReport;
  final GetTodayServices _getTodayServices;
  final GetMonthlyReports _getMonthlyReports;
  final GetWeeklyReport _getWeeklyReport;
  final GetBestWeekdayReport _getBestWeekdayReport;

  final RxBool isDailyLoading = false.obs;
  final RxBool isTodayServicesLoading = false.obs;
  final RxBool isMonthlyLoading = false.obs;
  final RxBool isWeeklyLoading = false.obs;
  final Rxn<DailyReport> dailyReport = Rxn<DailyReport>();
  final RxList<ServiceSummary> todayServices = <ServiceSummary>[].obs;
  final RxString todayServicesError = ''.obs;
  final RxList<MonthlyReport> monthlyReports = <MonthlyReport>[].obs;
  final RxList<WeeklyReport> weeklyReports = <WeeklyReport>[].obs;
  final Rxn<BestWeekdayReport> bestWeekday = Rxn<BestWeekdayReport>();
  final RxString errorMessage = ''.obs;

  static MonthlyReport? resolveHighlightMonth(List<MonthlyReport> list) {
    if (list.isEmpty) {
      return null;
    }
    final DateTime now = DateTime.now();
    for (final MonthlyReport m in list) {
      if (m.mes.year == now.year && m.mes.month == now.month) {
        return m;
      }
    }
    return list.first;
  }

  @override
  void onReady() {
    super.onReady();
    loadDaily();
    loadMonthly();
  }

  Future<void> loadDaily() async {
    isDailyLoading.value = true;
    isTodayServicesLoading.value = true;
    final DateTime now = DateTime.now();
    final List<dynamic> parallel = await Future.wait<dynamic>(<Future<dynamic>>[
      _getDailyReport(now),
      _getTodayServices(now),
    ]);
    final Either<Failure, DailyReport> dailyEither =
        parallel[0] as Either<Failure, DailyReport>;
    final Either<Failure, List<ServiceSummary>> servicesEither =
        parallel[1] as Either<Failure, List<ServiceSummary>>;
    dailyEither.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        dailyReport.value = null;
      },
      (DailyReport report) {
        errorMessage.value = '';
        dailyReport.value = report;
      },
    );
    servicesEither.fold(
      (Failure failure) {
        todayServices.clear();
        todayServicesError.value = failure.message;
      },
      (List<ServiceSummary> list) {
        todayServicesError.value = '';
        todayServices.assignAll(list);
      },
    );
    isDailyLoading.value = false;
    isTodayServicesLoading.value = false;
  }

  Future<void> loadTodayServices() async {
    isTodayServicesLoading.value = true;
    final Either<Failure, List<ServiceSummary>> result =
        await _getTodayServices(DateTime.now());
    result.fold(
      (Failure failure) {
        todayServices.clear();
        todayServicesError.value = failure.message;
      },
      (List<ServiceSummary> list) {
        todayServicesError.value = '';
        todayServices.assignAll(list);
      },
    );
    isTodayServicesLoading.value = false;
  }

  Future<void> loadMonthly() async {
    isMonthlyLoading.value = true;
    final Either<Failure, List<MonthlyReport>> result =
        await _getMonthlyReports();
    await result.fold(
      (Failure failure) async {
        errorMessage.value = failure.message;
        monthlyReports.clear();
        weeklyReports.clear();
        bestWeekday.value = null;
      },
      (List<MonthlyReport> list) async {
        errorMessage.value = '';
        monthlyReports.assignAll(list);
        final MonthlyReport? highlight = resolveHighlightMonth(list);
        if (highlight != null) {
          await loadWeekly(highlight.mes);
        } else {
          weeklyReports.clear();
          bestWeekday.value = null;
          isWeeklyLoading.value = false;
        }
      },
    );
    isMonthlyLoading.value = false;
  }

  Future<void> loadWeekly(DateTime month) async {
    isWeeklyLoading.value = true;
    final DateTime anchor = DateTime(month.year, month.month);
    final List<dynamic> parallel = await Future.wait<dynamic>(<Future<dynamic>>[
      _getWeeklyReport(anchor),
      _getBestWeekdayReport(anchor),
    ]);
    final Either<Failure, List<WeeklyReport>> weeklyEither =
        parallel[0] as Either<Failure, List<WeeklyReport>>;
    final Either<Failure, BestWeekdayReport?> bestEither =
        parallel[1] as Either<Failure, BestWeekdayReport?>;
    weeklyEither.fold(
      (Failure failure) {
        weeklyReports.clear();
      },
      (List<WeeklyReport> list) {
        weeklyReports.assignAll(list);
      },
    );
    bestEither.fold(
      (Failure failure) {
        bestWeekday.value = null;
      },
      (BestWeekdayReport? value) {
        bestWeekday.value = value;
      },
    );
    isWeeklyLoading.value = false;
  }
}
