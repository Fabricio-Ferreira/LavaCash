import 'package:equatable/equatable.dart';
import 'package:lava_cash/core/domain/entities/attendance_history_line.dart';

/// One page of flat rows from [ReportRepository.getAttendanceHistory] plus
/// distinct vehicle count for the current filters (not only this page).
/// [totalVehicles] is null when the RPC returned no rows and offset is past
/// the last page; keep the previous total in the controller.
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
