import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';
import 'package:lava_cash/core/domain/entities/attendance_history_load_result.dart';
import 'package:lava_cash/core/domain/entities/vehicle_attendance_history_group.dart';
import 'package:lava_cash/core/domain/reports/attendance_history_range_validation.dart';
import 'package:lava_cash/core/domain/reports/repositories/report_repository.dart';
import 'package:lava_cash/core/domain/reports/usecases/get_attendance_history.dart';
import '../utils/report_pdf_output_helper.dart';

class AttendanceHistoryController extends GetxController {
  AttendanceHistoryController({
    required GetAttendanceHistory getAttendanceHistory,
    required ReportRepository reportRepository,
  }) : _getAttendanceHistory = getAttendanceHistory,
       _reportRepository = reportRepository;

  final GetAttendanceHistory _getAttendanceHistory;
  final ReportRepository _reportRepository;

  static const int vehiclePageSize = 10;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<VehicleAttendanceHistoryGroup> groups =
      <VehicleAttendanceHistoryGroup>[].obs;
  final Rxn<int> totalVehicles = Rxn<int>();

  final Rx<DateTime> rangeStart = _defaultStart().obs;
  final Rx<DateTime> rangeEnd = _defaultEnd().obs;
  final RxString searchQuery = ''.obs;

  int _nextVehicleOffset = 0;

  /// Bumps on every full [load]. [loadMore] snapshots this so late responses
  /// after a refresh cannot append or mutate the wrong list.
  int _historyGeneration = 0;

  Timer? _debounce;

  static DateTime _today() {
    final DateTime n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime _defaultEnd() => _today();

  static DateTime _defaultStart() =>
      _today().subtract(const Duration(days: 6));

  bool get canLoadMore {
    final int? cap = totalVehicles.value;
    if (cap == null) {
      return false;
    }
    return groups.length < cap;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(
      AppConstants.attendanceHistorySearchDebounce,
      _executeDebouncedSearchLoad,
    );
  }

  void _executeDebouncedSearchLoad() {
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
    _debounce?.cancel();
    final int generation = ++_historyGeneration;
    isLoading.value = true;
    errorMessage.value = '';
    _nextVehicleOffset = 0;
    final String trimmed = searchQuery.value.trim();
    final Either<Failure, AttendanceHistoryLoadResult> result =
        await _getAttendanceHistory(
          startInclusive: rangeStart.value,
          endInclusive: rangeEnd.value,
          query: trimmed.isEmpty ? null : trimmed,
          vehicleLimit: vehiclePageSize,
          vehicleOffset: 0,
        );
    if (generation != _historyGeneration) {
      return;
    }
    result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        groups.clear();
        totalVehicles.value = null;
      },
      (AttendanceHistoryLoadResult r) {
        errorMessage.value = '';
        groups.assignAll(r.groups);
        totalVehicles.value = r.totalVehicles;
        _nextVehicleOffset = r.groups.length;
      },
    );
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (!canLoadMore || isLoadingMore.value || isLoading.value) {
      return;
    }
    final int generation = _historyGeneration;
    isLoadingMore.value = true;
    errorMessage.value = '';
    final String trimmed = searchQuery.value.trim();
    final Either<Failure, AttendanceHistoryLoadResult> result =
        await _getAttendanceHistory(
          startInclusive: rangeStart.value,
          endInclusive: rangeEnd.value,
          query: trimmed.isEmpty ? null : trimmed,
          vehicleLimit: vehiclePageSize,
          vehicleOffset: _nextVehicleOffset,
        );
    if (generation != _historyGeneration) {
      isLoadingMore.value = false;
      return;
    }
    result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
      },
      (AttendanceHistoryLoadResult r) {
        if (r.groups.isEmpty) {
          return;
        }
        groups.addAll(r.groups);
        if (r.totalVehicles != null) {
          totalVehicles.value = r.totalVehicles;
        }
        _nextVehicleOffset += r.groups.length;
      },
    );
    isLoadingMore.value = false;
  }

  Future<void> exportPdf() async {
    final String trimmed = searchQuery.value.trim();
    await runAttendanceHistoryPdfOutput(
      repository: _reportRepository,
      rangeStart: rangeStart.value,
      rangeEnd: rangeEnd.value,
      query: trimmed.isEmpty ? null : trimmed,
      sink: shareReportPdfSink,
    );
  }

  Future<void> printPdf() async {
    final String trimmed = searchQuery.value.trim();
    await runAttendanceHistoryPdfOutput(
      repository: _reportRepository,
      rangeStart: rangeStart.value,
      rangeEnd: rangeEnd.value,
      query: trimmed.isEmpty ? null : trimmed,
      sink: printReportPdfSink,
    );
  }
}
