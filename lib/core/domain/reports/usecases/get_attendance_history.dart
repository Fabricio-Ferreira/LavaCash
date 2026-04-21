import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/attendance_history_load_result.dart';
import 'package:lava_cash/core/domain/reports/attendance_history_grouping.dart';
import 'package:lava_cash/core/domain/reports/repositories/report_repository.dart';

class GetAttendanceHistory {
  GetAttendanceHistory({required ReportRepository repository})
    : _repository = repository;

  final ReportRepository _repository;

  Future<Either<Failure, AttendanceHistoryLoadResult>> call({
    required DateTime startInclusive,
    required DateTime endInclusive,
    String? query,
    int vehicleLimit = 10,
    int vehicleOffset = 0,
    bool fetchAllVehicles = false,
  }) async {
    final result = await _repository.getAttendanceHistory(
      startInclusive: startInclusive,
      endInclusive: endInclusive,
      query: query,
      vehicleLimit: vehicleLimit,
      vehicleOffset: vehicleOffset,
      fetchAllVehicles: fetchAllVehicles,
    );
    return result.map(
      (page) => AttendanceHistoryLoadResult(
        groups: groupAttendanceHistoryLines(page.lines),
        totalVehicles: page.totalVehicles,
      ),
    );
  }
}
