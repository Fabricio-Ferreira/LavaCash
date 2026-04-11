import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/get_interval_report.dart';
import '../../services/report_pdf_service.dart';
import '../../../license/presentation/services/license_status_refresh.dart';

class IntervalReportController extends GetxController {
  IntervalReportController({
    required GetIntervalReport getIntervalReport,
    required ReportRepository reportRepository,
  }) : _getIntervalReport = getIntervalReport,
       _reportRepository = reportRepository;

  final GetIntervalReport _getIntervalReport;
  final ReportRepository _reportRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<Map<String, dynamic>> summary = Rxn<Map<String, dynamic>>();

  final Rx<DateTime> rangeStart = _defaultStart().obs;
  final Rx<DateTime> rangeEnd = _defaultEnd().obs;

  static DateTime _today() {
    final DateTime n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime _defaultEnd() {
    return _today();
  }

  static DateTime _defaultStart() {
    return _today().subtract(const Duration(days: 6));
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void setRange(DateTime start, DateTime end) {
    final DateTime a = DateTime(start.year, start.month, start.day);
    final DateTime b = DateTime(end.year, end.month, end.day);
    if (a.isAfter(b)) {
      return;
    }
    if (a == rangeStart.value && b == rangeEnd.value) {
      return;
    }
    rangeStart.value = a;
    rangeEnd.value = b;
    load();
  }

  void applyLast7Days() {
    final DateTime t = _today();
    rangeEnd.value = t;
    rangeStart.value = t.subtract(const Duration(days: 6));
    load();
  }

  void applyThisWeek() {
    final DateTime t = _today();
    final int daysFromMonday = t.weekday - DateTime.monday;
    final DateTime monday = t.subtract(Duration(days: daysFromMonday));
    final DateTime sunday = monday.add(const Duration(days: 6));
    rangeStart.value = monday;
    rangeEnd.value = sunday.isAfter(t) ? t : sunday;
    load();
  }

  void applyThisMonth() {
    final DateTime t = _today();
    final DateTime first = DateTime(t.year, t.month, 1);
    final DateTime lastOfMonth = DateTime(t.year, t.month + 1, 0);
    rangeStart.value = first;
    rangeEnd.value = lastOfMonth.isAfter(t) ? t : lastOfMonth;
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    final Either<Failure, Map<String, dynamic>> result =
        await _getIntervalReport(rangeStart.value, rangeEnd.value);
    result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        summary.value = null;
      },
      (Map<String, dynamic> map) {
        errorMessage.value = '';
        summary.value = map;
      },
    );
    isLoading.value = false;
  }

  Future<void> exportPdf() async {
    final bool ok = await LicenseStatusRefresh.verifyAndSyncOrExit();
    if (!ok) {
      return;
    }
    final ReportPdfService pdf = Get.find<ReportPdfService>();
    final AppGlobalController global = Get.find<AppGlobalController>();
    final DateTime start = rangeStart.value;
    final DateTime end = rangeEnd.value;
    final PackageInfo info = await PackageInfo.fromPlatform();
    final Either<Failure, Map<String, dynamic>> sumRes =
        await _reportRepository.getIntervalSummary(start, end);
    await sumRes.fold(
      (Failure f) async {
        AppSnackbar.showError(f.message);
      },
      (Map<String, dynamic> summaryMap) async {
        final Either<Failure, List<Map<String, dynamic>>> attRes =
            await _reportRepository.getIntervalAttendanceRows(start, end);
        await attRes.fold(
          (Failure f) async {
            AppSnackbar.showError(f.message);
          },
          (List<Map<String, dynamic>> att) async {
            final Either<Failure, List<Map<String, dynamic>>> expRes =
                await _reportRepository.getIntervalExpenseRows(start, end);
            await expRes.fold(
              (Failure f) async {
                AppSnackbar.showError(f.message);
              },
              (List<Map<String, dynamic>> exp) async {
                final Uint8List bytes = await pdf.generateIntervalReportPdf(
                  companyName: global.establishmentName.value,
                  rangeStart: start,
                  rangeEnd: end,
                  summary: summaryMap,
                  attendances: att,
                  expenses: exp,
                  appVersionLabel: '${info.version}+${info.buildNumber}',
                );
                final String name =
                    'lavacash-relatorio-periodo-'
                    '${DateFormat('yyyy-MM-dd').format(start)}_'
                    '${DateFormat('yyyy-MM-dd').format(end)}.pdf';
                await pdf.sharePdf(bytes: bytes, filename: name);
                AppSnackbar.showSuccess('PDF pronto para compartilhar.');
              },
            );
          },
        );
      },
    );
  }

  Future<void> printPdf() async {
    final bool ok = await LicenseStatusRefresh.verifyAndSyncOrExit();
    if (!ok) {
      return;
    }
    final ReportPdfService pdf = Get.find<ReportPdfService>();
    final AppGlobalController global = Get.find<AppGlobalController>();
    final DateTime start = rangeStart.value;
    final DateTime end = rangeEnd.value;
    final PackageInfo info = await PackageInfo.fromPlatform();
    final Either<Failure, Map<String, dynamic>> sumRes =
        await _reportRepository.getIntervalSummary(start, end);
    await sumRes.fold(
      (Failure f) async {
        AppSnackbar.showError(f.message);
      },
      (Map<String, dynamic> summaryMap) async {
        final Either<Failure, List<Map<String, dynamic>>> attRes =
            await _reportRepository.getIntervalAttendanceRows(start, end);
        await attRes.fold(
          (Failure f) async {
            AppSnackbar.showError(f.message);
          },
          (List<Map<String, dynamic>> att) async {
            final Either<Failure, List<Map<String, dynamic>>> expRes =
                await _reportRepository.getIntervalExpenseRows(start, end);
            await expRes.fold(
              (Failure f) async {
                AppSnackbar.showError(f.message);
              },
              (List<Map<String, dynamic>> exp) async {
                final Uint8List bytes = await pdf.generateIntervalReportPdf(
                  companyName: global.establishmentName.value,
                  rangeStart: start,
                  rangeEnd: end,
                  summary: summaryMap,
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
}
