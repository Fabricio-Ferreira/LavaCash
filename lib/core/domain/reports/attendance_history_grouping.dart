import 'package:lava_cash/core/domain/entities/attendance_history_line.dart';
import 'package:lava_cash/core/domain/entities/vehicle_attendance_history_group.dart';

/// Groups flat [AttendanceHistoryLine] rows by vehicle; sorts groups by
/// cliente nome then placa. Preserves per-vehicle order (newest first).
List<VehicleAttendanceHistoryGroup> groupAttendanceHistoryLines(
  List<AttendanceHistoryLine> lines,
) {
  final Map<String, List<AttendanceHistoryLine>> byVehicleId =
      <String, List<AttendanceHistoryLine>>{};
  final List<String> insertionOrder = <String>[];
  for (final AttendanceHistoryLine line in lines) {
    final List<AttendanceHistoryLine>? existing =
        byVehicleId[line.veiculoId];
    if (existing == null) {
      insertionOrder.add(line.veiculoId);
      byVehicleId[line.veiculoId] = <AttendanceHistoryLine>[line];
    } else {
      existing.add(line);
    }
  }
  final List<VehicleAttendanceHistoryGroup> groups =
      <VehicleAttendanceHistoryGroup>[];
  for (final String veiculoId in insertionOrder) {
    final List<AttendanceHistoryLine> gLines = byVehicleId[veiculoId]!;
    final AttendanceHistoryLine first = gLines.first;
    groups.add(
      VehicleAttendanceHistoryGroup(
        veiculoId: veiculoId,
        placa: first.placa,
        clienteNome: first.clienteNome,
        totalAtendimentos: gLines.length,
        lines: List<AttendanceHistoryLine>.from(gLines),
      ),
    );
  }
  groups.sort((VehicleAttendanceHistoryGroup a, VehicleAttendanceHistoryGroup b) {
    final int byName = a.clienteNome.compareTo(b.clienteNome);
    if (byName != 0) {
      return byName;
    }
    return a.placa.compareTo(b.placa);
  });
  return groups;
}
