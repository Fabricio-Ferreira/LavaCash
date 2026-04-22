import 'package:flutter_test/flutter_test.dart';
import 'package:lava_cash/core/domain/entities/attendance_history_line.dart';
import 'package:lava_cash/core/domain/entities/vehicle_attendance_history_group.dart';
import 'package:lava_cash/core/domain/reports/attendance_history_grouping.dart';

void main() {
  group('groupAttendanceHistoryLines', () {
    test('groups by veiculoId and sorts groups by cliente nome then placa', () {
      final DateTime t1 = DateTime(2025, 4, 10, 14, 0);
      final DateTime t2 = DateTime(2025, 4, 9, 10, 0);
      final DateTime t3 = DateTime(2025, 4, 8, 8, 0);
      final List<AttendanceHistoryLine> lines = <AttendanceHistoryLine>[
        AttendanceHistoryLine(
          atendimentoId: 'a1',
          veiculoId: 'v-b',
          placa: 'BBB1B11',
          clienteNome: 'Bruno',
          horaEntradaLocal: t1,
          valor: 50,
        ),
        AttendanceHistoryLine(
          atendimentoId: 'a2',
          veiculoId: 'v-a',
          placa: 'AAA1A11',
          clienteNome: 'Ana',
          horaEntradaLocal: t2,
          valor: 40,
        ),
        AttendanceHistoryLine(
          atendimentoId: 'a3',
          veiculoId: 'v-b',
          placa: 'BBB1B11',
          clienteNome: 'Bruno',
          horaEntradaLocal: t3,
          valor: 30,
        ),
      ];
      final List<VehicleAttendanceHistoryGroup> groups =
          groupAttendanceHistoryLines(lines);
      expect(groups.length, 2);
      expect(groups[0].clienteNome, 'Ana');
      expect(groups[0].totalAtendimentos, 1);
      expect(groups[1].clienteNome, 'Bruno');
      expect(groups[1].totalAtendimentos, 2);
      expect(groups[1].lines.map((AttendanceHistoryLine l) => l.atendimentoId),
          <String>['a1', 'a3'],
        );
    });

    test('empty input yields empty list', () {
      expect(groupAttendanceHistoryLines(<AttendanceHistoryLine>[]), isEmpty);
    });
  });
}
