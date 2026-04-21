import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../core/domain/reports/attendance_history_range_validation.dart';
import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/reports/repositories/report_repository.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_interval_report.dart';
import '../utils/report_pdf_output_helper.dart';

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
    final String? rangeError = AttendanceHistoryRangeValidation.validate(a, b);
    if (rangeError != null) {
      errorMessage.value = rangeError;
      return;
    }
    errorMessage.value = '';
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
    await runIntervalReportPdfOutput(
      repository: _reportRepository,
      rangeStart: rangeStart.value,
      rangeEnd: rangeEnd.value,
      sink: shareReportPdfSink,
    );
  }

  Future<void> printPdf() async {
    await runIntervalReportPdfOutput(
      repository: _reportRepository,
      rangeStart: rangeStart.value,
      rangeEnd: rangeEnd.value,
      sink: printReportPdfSink,
    );
  }
}
