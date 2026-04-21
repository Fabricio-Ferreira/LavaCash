import 'package:equatable/equatable.dart';

import 'vehicle_attendance_history_group.dart';

/// Grouped attendance history for UI with server total vehicle count.
class AttendanceHistoryLoadResult extends Equatable {
  const AttendanceHistoryLoadResult({
    required this.groups,
    required this.totalVehicles,
  });

  final List<VehicleAttendanceHistoryGroup> groups;
  final int? totalVehicles;

  @override
  List<Object?> get props => <Object?>[groups, totalVehicles];
}
