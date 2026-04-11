import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_snackbar.dart';
import 'package:lava_cash/core/domain/entities/best_weekday_report.dart';
import 'package:lava_cash/core/domain/entities/daily_report.dart';
import 'package:lava_cash/core/domain/entities/monthly_report.dart';
import 'package:lava_cash/core/domain/entities/service_summary.dart';
import 'package:lava_cash/core/domain/entities/weekly_report.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_best_weekday_report.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_daily_report.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_in_progress_services.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_monthly_reports.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_today_services.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_weekly_report.dart';
import 'package:lava_cash/core/domain/reports/repositories/report_repository.dart';
import '../../services/report_pdf_service.dart';
import 'package:lava_cash/features/license/presentation/services/license_status_refresh.dart';

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

  /// Calendar day for daily report, PDF, and [loadDaily] / today-services list.
  final Rx<DateTime> dailyReportDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).obs;

  /// First day of month for monthly UI, weekly RPCs, and monthly PDF.
  final Rx<DateTime> monthlyReportMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  ).obs;

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

  /// Row in [list] matching [monthAnchor] (year + month), or null.
  static MonthlyReport? resolveMonthInList(
    List<MonthlyReport> list,
    DateTime monthAnchor,
  ) {
    for (final MonthlyReport m in list) {
      if (m.mes.year == monthAnchor.year && m.mes.month == monthAnchor.month) {
        return m;
      }
    }
    return null;
  }

  void setDailyReportDay(DateTime d) {
    final DateTime normalized = DateTime(d.year, d.month, d.day);
    if (dailyReportDay.value == normalized) {
      return;
    }
    dailyReportDay.value = normalized;
    loadDaily();
  }

  void setMonthlyReportMonth(DateTime m) {
    final DateTime first = DateTime(m.year, m.month, 1);
    if (monthlyReportMonth.value.year == first.year &&
        monthlyReportMonth.value.month == first.month) {
      return;
    }
    monthlyReportMonth.value = first;
    loadWeekly(first);
  }

  /// Call when switching to the dashboard tab so KPIs stay “hoje / este mês”.
  void resetSelectionsToTodayAndThisMonth() {
    final DateTime n = DateTime.now();
    final DateTime today = DateTime(n.year, n.month, n.day);
    final DateTime monthFirst = DateTime(n.year, n.month, 1);
    dailyReportDay.value = today;
    monthlyReportMonth.value = monthFirst;
    loadDaily();
    loadWeekly(monthFirst);
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
    final DateTime day = dailyReportDay.value;
    final List<dynamic> parallel = await Future.wait<dynamic>(<Future<dynamic>>[
      _getDailyReport(day),
      _getTodayServices(day),
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
        await _getTodayServices(dailyReportDay.value);
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
        await loadWeekly(monthlyReportMonth.value);
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

  Future<void> exportDailyPdf() async {
    final bool ok = await LicenseStatusRefresh.verifyAndSyncOrExit();
    if (!ok) {
      return;
    }
    final ReportRepository repo = Get.find<ReportRepository>();
    final ReportPdfService pdf = Get.find<ReportPdfService>();
    final AppGlobalController global = Get.find<AppGlobalController>();
    final DateTime day = dailyReportDay.value;
    final PackageInfo info = await PackageInfo.fromPlatform();
    final Either<Failure, Map<String, dynamic>> sumRes =
        await repo.getPdfDailySummary(day);
    await sumRes.fold(
      (Failure f) async {
        AppSnackbar.showError(f.message);
      },
      (Map<String, dynamic> summary) async {
        final Either<Failure, List<Map<String, dynamic>>> attRes =
            await repo.getPdfDailyAttendanceRows(day);
        await attRes.fold(
          (Failure f) async {
            AppSnackbar.showError(f.message);
          },
          (List<Map<String, dynamic>> att) async {
            final Either<Failure, List<Map<String, dynamic>>> expRes =
                await repo.getPdfDailyExpenseRows(day);
            await expRes.fold(
              (Failure f) async {
                AppSnackbar.showError(f.message);
              },
              (List<Map<String, dynamic>> exp) async {
                final Uint8List bytes = await pdf.generateDailyReportPdf(
                  companyName: global.establishmentName.value,
                  reportDate: day,
                  summary: summary,
                  attendances: att,
                  expenses: exp,
                  appVersionLabel: '${info.version}+${info.buildNumber}',
                );
                final String name =
                    'lavacash-relatorio-diario-${DateFormat('yyyy-MM-dd').format(day)}.pdf';
                await pdf.sharePdf(bytes: bytes, filename: name);
                AppSnackbar.showSuccess('PDF pronto para compartilhar.');
              },
            );
          },
        );
      },
    );
  }

  Future<void> printDailyPdf() async {
    final bool ok = await LicenseStatusRefresh.verifyAndSyncOrExit();
    if (!ok) {
      return;
    }
    final ReportRepository repo = Get.find<ReportRepository>();
    final ReportPdfService pdf = Get.find<ReportPdfService>();
    final AppGlobalController global = Get.find<AppGlobalController>();
    final DateTime day = dailyReportDay.value;
    final PackageInfo info = await PackageInfo.fromPlatform();
    final Either<Failure, Map<String, dynamic>> sumRes =
        await repo.getPdfDailySummary(day);
    await sumRes.fold(
      (Failure f) async {
        AppSnackbar.showError(f.message);
      },
      (Map<String, dynamic> summary) async {
        final Either<Failure, List<Map<String, dynamic>>> attRes =
            await repo.getPdfDailyAttendanceRows(day);
        await attRes.fold(
          (Failure f) async {
            AppSnackbar.showError(f.message);
          },
          (List<Map<String, dynamic>> att) async {
            final Either<Failure, List<Map<String, dynamic>>> expRes =
                await repo.getPdfDailyExpenseRows(day);
            await expRes.fold(
              (Failure f) async {
                AppSnackbar.showError(f.message);
              },
              (List<Map<String, dynamic>> exp) async {
                final Uint8List bytes = await pdf.generateDailyReportPdf(
                  companyName: global.establishmentName.value,
                  reportDate: day,
                  summary: summary,
                  attendances: att,
                  expenses: exp,
                  appVersionLabel: '${info.version}+${info.buildNumber}',
                );
                await pdf.printPdf(bytes);
              },
            );
          },
        );
      },
    );
  }

  Future<void> exportMonthlyPdf() async {
    final bool ok = await LicenseStatusRefresh.verifyAndSyncOrExit();
    if (!ok) {
      return;
    }
    final DateTime month = monthlyReportMonth.value;
    await loadWeekly(month);
    final ReportRepository repo = Get.find<ReportRepository>();
    final ReportPdfService pdf = Get.find<ReportPdfService>();
    final AppGlobalController global = Get.find<AppGlobalController>();
    final PackageInfo info = await PackageInfo.fromPlatform();
    final Either<Failure, Map<String, dynamic>> sumRes =
        await repo.getPdfMonthlySummary(month);
    await sumRes.fold(
      (Failure f) async {
        AppSnackbar.showError(f.message);
      },
      (Map<String, dynamic> summary) async {
        final Uint8List bytes = await pdf.generateMonthlyReportPdf(
          companyName: global.establishmentName.value,
          referenceMonth: DateTime(month.year, month.month),
          summary: summary,
          weeklyReports: weeklyReports.toList(),
          bestWeekday: bestWeekday.value,
          appVersionLabel: '${info.version}+${info.buildNumber}',
        );
        final String name =
            'lavacash-relatorio-mensal-${DateFormat('yyyy-MM').format(month)}.pdf';
        await pdf.sharePdf(bytes: bytes, filename: name);
        AppSnackbar.showSuccess('PDF pronto para compartilhar.');
      },
    );
  }

  Future<void> printMonthlyPdf() async {
    final bool ok = await LicenseStatusRefresh.verifyAndSyncOrExit();
    if (!ok) {
      return;
    }
    final DateTime month = monthlyReportMonth.value;
    await loadWeekly(month);
    final ReportRepository repo = Get.find<ReportRepository>();
    final ReportPdfService pdf = Get.find<ReportPdfService>();
    final AppGlobalController global = Get.find<AppGlobalController>();
    final PackageInfo info = await PackageInfo.fromPlatform();
    final Either<Failure, Map<String, dynamic>> sumRes =
        await repo.getPdfMonthlySummary(month);
    await sumRes.fold(
      (Failure f) async {
        AppSnackbar.showError(f.message);
      },
      (Map<String, dynamic> summary) async {
        final Uint8List bytes = await pdf.generateMonthlyReportPdf(
          companyName: global.establishmentName.value,
          referenceMonth: DateTime(month.year, month.month),
          summary: summary,
          weeklyReports: weeklyReports.toList(),
          bestWeekday: bestWeekday.value,
          appVersionLabel: '${info.version}+${info.buildNumber}',
        );
        await pdf.printPdf(bytes);
      },
    );
  }
}
