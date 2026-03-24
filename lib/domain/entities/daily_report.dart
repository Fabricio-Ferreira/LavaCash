import 'package:equatable/equatable.dart';

class DailyReport extends Equatable {
  const DailyReport({
    required this.totalCarros,
    required this.totalRecebido,
    required this.totalPorFormaPagamento,
  });

  final int totalCarros;
  final double totalRecebido;
  final Map<String, double> totalPorFormaPagamento;

  @override
  List<Object?> get props => [totalCarros, totalRecebido, totalPorFormaPagamento];
}
