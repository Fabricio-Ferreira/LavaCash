import 'package:equatable/equatable.dart';

import 'attendance_history_line.dart';

/// Attendance lines for one vehicle (same order as API: newest first).
class VehicleAttendanceHistoryGroup extends Equatable {
  const VehicleAttendanceHistoryGroup({
    required this.veiculoId,
    required this.placa,
    required this.clienteNome,
    required this.totalAtendimentos,
    required this.lines,
  });

  final String veiculoId;
  final String placa;
  final String clienteNome;
  final int totalAtendimentos;
  final List<AttendanceHistoryLine> lines;

  @override
  List<Object?> get props => <Object?>[
    veiculoId,
    placa,
    clienteNome,
    totalAtendimentos,
    lines,
  ];
}
