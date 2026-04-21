import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_snackbar.dart';
import 'package:lava_cash/core/domain/entities/attendance_history_page_result.dart';
import 'package:lava_cash/core/domain/entities/best_weekday_report.dart';
import 'package:lava_cash/core/domain/entities/vehicle_attendance_history_group.dart';
import 'package:lava_cash/core/domain/reports/attendance_history_grouping.dart';
import 'package:lava_cash/core/domain/entities/weekly_report.dart';
import 'package:lava_cash/core/domain/reports/repositories/report_repository.dart';
import '../../services/report_pdf_service.dart';
import 'package:lava_cash/features/license/presentation/services/license_status_refresh.dart';

/// Delivers generated PDF bytes (share, print, or custom).
typedef ReportPdfBytesSink = Future<void> Function({
  required ReportPdfService pdf,
  required Uint8List bytes,
  required String filename,
});

Future<void> shareReportPdfSink({
  required ReportPdfService pdf,
  required Uint8List bytes,
  required String filename,
}) async {
  await pdf.sharePdf(bytes: bytes, filename: filename);
  AppSnackbar.showSuccess('PDF pronto para compartilhar.');
}

Future<void> printReportPdfSink({
  required ReportPdfService pdf,
  required Uint8List bytes,
  required String filename,
}) async {
  await pdf.printPdf(bytes);
}

Future<void> runAttendanceHistoryPdfOutput({
  required ReportRepository repository,
  required DateTime rangeStart,
  required DateTime rangeEnd,
  required String? query,
  required ReportPdfBytesSink sink,
}) async {
  final bool ok = await LicenseStatusRefresh.verifyAndSyncOrExit();
  if (!ok) {
    return;
  }
  final ReportPdfService pdf = Get.find<ReportPdfService>();
  final AppGlobalController global = Get.find<AppGlobalController>();
  final PackageInfo info = await PackageInfo.fromPlatform();
  final Either<Failure, AttendanceHistoryPageResult> res =
      await repository.getAttendanceHistory(
        startInclusive: rangeStart,
        endInclusive: rangeEnd,
        query: query,
        fetchAllVehicles: true,
      );
  await res.fold(
    (Failure f) async {
      AppSnackbar.showError(f.message);
    },
    (AttendanceHistoryPageResult page) async {
      final List<VehicleAttendanceHistoryGroup> groups =
          groupAttendanceHistoryLines(page.lines);
      final String searchDescription =
          (query == null || query.trim().isEmpty)
          ? 'Busca: todos'
          : 'Busca: ${query.trim()}';
      final Uint8List bytes = await pdf.generateAttendanceHistoryPdf(
        companyName: global.establishmentName.value,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        searchDescription: searchDescription,
        groups: groups,
        appVersionLabel: '${info.version}+${info.buildNumber}',
      );
      final String filename =
          'lavacash-historico-atendimentos-'
          '${DateFormat('yyyy-MM-dd').format(rangeStart)}_'
          '${DateFormat('yyyy-MM-dd').format(rangeEnd)}.pdf';
      await sink(
        pdf: pdf,
        bytes: bytes,
        filename: filename,
      );
    },
  );
}

Future<void> runIntervalReportPdfOutput({
  required ReportRepository repository,
  required DateTime rangeStart,
  required DateTime rangeEnd,
  required ReportPdfBytesSink sink,
}) async {
  final bool ok = await LicenseStatusRefresh.verifyAndSyncOrExit();
  if (!ok) {
    return;
  }
  final ReportPdfService pdf = Get.find<ReportPdfService>();
  final AppGlobalController global = Get.find<AppGlobalController>();
  final PackageInfo info = await PackageInfo.fromPlatform();
  final Either<Failure, Map<String, dynamic>> sumRes =
      await repository.getIntervalSummary(rangeStart, rangeEnd);
  await sumRes.fold(
    (Failure f) async {
      AppSnackbar.showError(f.message);
    },
    (Map<String, dynamic> summaryMap) async {
      final Either<Failure, List<Map<String, dynamic>>> attRes =
          await repository.getIntervalAttendanceRows(rangeStart, rangeEnd);
      await attRes.fold(
        (Failure f) async {
          AppSnackbar.showError(f.message);
        },
        (List<Map<String, dynamic>> att) async {
          final Either<Failure, List<Map<String, dynamic>>> expRes =
              await repository.getIntervalExpenseRows(rangeStart, rangeEnd);
          await expRes.fold(
            (Failure f) async {
              AppSnackbar.showError(f.message);
            },
            (List<Map<String, dynamic>> exp) async {
              final Uint8List bytes = await pdf.generateIntervalReportPdf(
                companyName: global.establishmentName.value,
                rangeStart: rangeStart,
                rangeEnd: rangeEnd,
                summary: summaryMap,
                attendances: att,
                expenses: exp,
                appVersionLabel: '${info.version}+${info.buildNumber}',
              );
              final String filename =
                  'lavacash-relatorio-periodo-'
                  '${DateFormat('yyyy-MM-dd').format(rangeStart)}_'
                  '${DateFormat('yyyy-MM-dd').format(rangeEnd)}.pdf';
              await sink(
                pdf: pdf,
                bytes: bytes,
                filename: filename,
              );
            },
          );
        },
      );
    },
  );
}

Future<void> runDailyReportPdfOutput({
  required ReportRepository repository,
  required DateTime day,
  required ReportPdfBytesSink sink,
}) async {
  final bool ok = await LicenseStatusRefresh.verifyAndSyncOrExit();
  if (!ok) {
    return;
  }
  final ReportPdfService pdf = Get.find<ReportPdfService>();
  final AppGlobalController global = Get.find<AppGlobalController>();
  final PackageInfo info = await PackageInfo.fromPlatform();
  final Either<Failure, Map<String, dynamic>> sumRes =
      await repository.getPdfDailySummary(day);
  await sumRes.fold(
    (Failure f) async {
      AppSnackbar.showError(f.message);
    },
    (Map<String, dynamic> summary) async {
      final Either<Failure, List<Map<String, dynamic>>> attRes =
          await repository.getPdfDailyAttendanceRows(day);
      await attRes.fold(
        (Failure f) async {
          AppSnackbar.showError(f.message);
        },
        (List<Map<String, dynamic>> att) async {
          final Either<Failure, List<Map<String, dynamic>>> expRes =
              await repository.getPdfDailyExpenseRows(day);
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
              final String filename =
                  'lavacash-relatorio-diario-${DateFormat('yyyy-MM-dd').format(day)}.pdf';
              await sink(
                pdf: pdf,
                bytes: bytes,
                filename: filename,
              );
            },
          );
        },
      );
    },
  );
}

Future<void> runMonthlyReportPdfOutput({
  required ReportRepository repository,
  required DateTime month,
  required List<WeeklyReport> weeklyReports,
  required BestWeekdayReport? bestWeekday,
  required ReportPdfBytesSink sink,
}) async {
  final bool ok = await LicenseStatusRefresh.verifyAndSyncOrExit();
  if (!ok) {
    return;
  }
  final ReportPdfService pdf = Get.find<ReportPdfService>();
  final AppGlobalController global = Get.find<AppGlobalController>();
  final PackageInfo info = await PackageInfo.fromPlatform();
  final Either<Failure, Map<String, dynamic>> sumRes =
      await repository.getPdfMonthlySummary(month);
  await sumRes.fold(
    (Failure f) async {
      AppSnackbar.showError(f.message);
    },
    (Map<String, dynamic> summary) async {
      final Uint8List bytes = await pdf.generateMonthlyReportPdf(
        companyName: global.establishmentName.value,
        referenceMonth: DateTime(month.year, month.month),
        summary: summary,
        weeklyReports: weeklyReports,
        bestWeekday: bestWeekday,
        appVersionLabel: '${info.version}+${info.buildNumber}',
      );
      final String filename =
          'lavacash-relatorio-mensal-${DateFormat('yyyy-MM').format(month)}.pdf';
      await sink(
        pdf: pdf,
        bytes: bytes,
        filename: filename,
      );
    },
  );
}
