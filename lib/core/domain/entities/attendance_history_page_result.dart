import 'package:equatable/equatable.dart';
import 'package:lava_cash/core/domain/entities/attendance_history_line.dart';

/// One page of flat rows from [ReportRepository.getAttendanceHistory] plus
/// distinct vehicle count for the current filters (not only this page).
/// [totalVehicles] is null on later pages when the RPC omits it; the first
/// page should always return an int (0+). Refresh uses that value as-is.
class AttendanceHistoryPageResult extends Equatable {
  const AttendanceHistoryPageResult({
    required this.lines,
    required this.totalVehicles,
  });

  final List<AttendanceHistoryLine> lines;
  final int? totalVehicles;

  @override
  List<Object?> get props => <Object?>[lines, totalVehicles];
}
