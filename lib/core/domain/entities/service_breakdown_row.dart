import 'package:equatable/equatable.dart';

class ServiceBreakdownRow extends Equatable {
  const ServiceBreakdownRow({
    required this.nomeExibicao,
    required this.quantidade,
    required this.faturamento,
  });

  final String nomeExibicao;
  final int quantidade;
  final double faturamento;

  @override
  List<Object?> get props => <Object?>[nomeExibicao, quantidade, faturamento];
}
