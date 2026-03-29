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
import '../../domain/usecases/get_in_progress_services.dart';
import '../../domain/usecases/get_monthly_reports.dart';
import '../../domain/usecases/get_today_services.dart';
import '../../domain/usecases/get_weekly_report.dart';

class ReportController extends GetxController {
  ReportController({
    required GetDailyReport getDailyReport,
    required GetTodayServices getTodayServices,
    required GetInProgressServices getInProgressServices,
    required GetMonthlyReports getMonthlyReports,
    required GetWeeklyReport getWeeklyReport,
    required GetBestWeekdayReport getBestWeekdayReport,
  }) : _getDailyReport = getDailyReport,
       _getTodayServices = getTodayServices,
       _getInProgressServices = getInProgressServices,
       _getMonthlyReports = getMonthlyReports,
       _getWeeklyReport = getWeeklyReport,
       _getBestWeekdayReport = getBestWeekdayReport;

  final GetDailyReport _getDailyReport;
  final GetTodayServices _getTodayServices;
  final GetInProgressServices _getInProgressServices;
  final GetMonthlyReports _getMonthlyReports;
  final GetWeeklyReport _getWeeklyReport;
  final GetBestWeekdayReport _getBestWeekdayReport;

  final RxBool isDailyLoading = false.obs;
  final RxBool isTodayServicesLoading = false.obs;
  final RxBool isInProgressLoading = false.obs;
  final RxBool isMonthlyLoading = false.obs;
  final RxBool isWeeklyLoading = false.obs;
  final Rxn<DailyReport> dailyReport = Rxn<DailyReport>();
  final RxList<ServiceSummary> todayServices = <ServiceSummary>[].obs;
  final RxString todayServicesError = ''.obs;
  final RxList<ServiceSummary> inProgressServices = <ServiceSummary>[].obs;
  final RxString inProgressError = ''.obs;
  final RxList<MonthlyReport> monthlyReports = <MonthlyReport>[].obs;
  final RxList<WeeklyReport> weeklyReports = <WeeklyReport>[].obs;
  final Rxn<BestWeekdayReport> bestWeekday = Rxn<BestWeekdayReport>();
  final RxString errorMessage = ''.obs;

  static const Duration _reportStaleThreshold = Duration(minutes: 5);

  DateTime? _lastSuccessfulDailyLoadAt;

  DateTime? _lastSuccessfulMonthlyLoadAt;

  /// Refreshes daily/monthly data only if the last successful load is older
  /// than [_reportStaleThreshold] (e.g. after switching home tabs).
  void refreshIfStaleForHomeTab() {
    final DateTime now = DateTime.now();
    if (_lastSuccessfulDailyLoadAt == null ||
        now.difference(_lastSuccessfulDailyLoadAt!) > _reportStaleThreshold) {
      loadDaily();
    }
    if (_lastSuccessfulMonthlyLoadAt == null ||
        now.difference(_lastSuccessfulMonthlyLoadAt!) > _reportStaleThreshold) {
      loadMonthly();
    }
  }

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
    isInProgressLoading.value = true;
    final DateTime now = DateTime.now();
    final List<dynamic> parallel = await Future.wait<dynamic>(<Future<dynamic>>[
      _getDailyReport(now),
      _getTodayServices(now),
      _getInProgressServices(),
    ]);
    final Either<Failure, DailyReport> dailyEither =
        parallel[0] as Either<Failure, DailyReport>;
    final Either<Failure, List<ServiceSummary>> servicesEither =
        parallel[1] as Either<Failure, List<ServiceSummary>>;
    final Either<Failure, List<ServiceSummary>> inProgressEither =
        parallel[2] as Either<Failure, List<ServiceSummary>>;
    dailyEither.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        dailyReport.value = null;
      },
      (DailyReport report) {
        errorMessage.value = '';
        dailyReport.value = report;
        _lastSuccessfulDailyLoadAt = DateTime.now();
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
    inProgressEither.fold(
      (Failure failure) {
        inProgressServices.clear();
        inProgressError.value = failure.message;
      },
      (List<ServiceSummary> list) {
        inProgressError.value = '';
        inProgressServices.assignAll(list);
      },
    );
    isDailyLoading.value = false;
    isTodayServicesLoading.value = false;
    isInProgressLoading.value = false;
  }

  Future<void> loadInProgressServices() async {
    isInProgressLoading.value = true;
    final Either<Failure, List<ServiceSummary>> result =
        await _getInProgressServices();
    result.fold(
      (Failure failure) {
        inProgressServices.clear();
        inProgressError.value = failure.message;
      },
      (List<ServiceSummary> list) {
        inProgressError.value = '';
        inProgressServices.assignAll(list);
      },
    );
    isInProgressLoading.value = false;
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
        _lastSuccessfulMonthlyLoadAt = DateTime.now();
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
