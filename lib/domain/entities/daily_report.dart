import 'package:equatable/equatable.dart';

class DailyReport extends Equatable {
  const DailyReport({
    required this.totalCarros,
    required this.totalRecebido,
    required this.totalPorFormaPagamento,
    this.emAndamento = 0,
  });

  final int totalCarros;
  final double totalRecebido;
  final Map<String, double> totalPorFormaPagamento;
  final int emAndamento;

  @override
  List<Object?> get props =>
      [totalCarros, totalRecebido, totalPorFormaPagamento, emAndamento];
}
