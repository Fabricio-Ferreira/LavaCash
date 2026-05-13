import 'package:equatable/equatable.dart';

class AttendanceServiceLine extends Equatable {
  const AttendanceServiceLine({
    required this.id,
    required this.atendimentoId,
    this.servicoCatalogoId,
    required this.nome,
    required this.valor,
    this.observacao,
    required this.sortOrder,
  });

  final String id;
  final String atendimentoId;
  final String? servicoCatalogoId;
  final String nome;
  final double valor;
  final String? observacao;
  final int sortOrder;

  @override
  List<Object?> get props => <Object?>[
    id,
    atendimentoId,
    servicoCatalogoId,
    nome,
    valor,
    observacao,
    sortOrder,
  ];
}
