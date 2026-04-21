import 'package:equatable/equatable.dart';

/// One finalized service row from [ReportRepository.getAttendanceHistory].
class AttendanceHistoryLine extends Equatable {
  const AttendanceHistoryLine({
    required this.atendimentoId,
    required this.veiculoId,
    required this.placa,
    required this.clienteNome,
    required this.horaEntradaLocal,
    this.valor,
    this.formaPagamento,
  });

  final String atendimentoId;
  final String veiculoId;
  final String placa;
  final String clienteNome;
  final DateTime horaEntradaLocal;
  final double? valor;
  final String? formaPagamento;

  @override
  List<Object?> get props => <Object?>[
    atendimentoId,
    veiculoId,
    placa,
    clienteNome,
    horaEntradaLocal,
    valor,
    formaPagamento,
  ];
}
