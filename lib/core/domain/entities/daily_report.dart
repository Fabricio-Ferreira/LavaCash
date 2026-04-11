import 'package:equatable/equatable.dart';

class DailyReport extends Equatable {
  const DailyReport({
    required this.totalCarros,
    required this.totalRecebido,
    required this.totalDespesas,
    required this.totalPorFormaPagamento,
    this.emAndamento = 0,
  });

  final int totalCarros;
  final double totalRecebido;
  /// Sum of [despesas.valor] for [data_referencia] = calendar day.
  final double totalDespesas;
  final Map<String, double> totalPorFormaPagamento;
  final int emAndamento;

  @override
  List<Object?> get props => [
    totalCarros,
    totalRecebido,
    totalDespesas,
    totalPorFormaPagamento,
    emAndamento,
  ];
}
