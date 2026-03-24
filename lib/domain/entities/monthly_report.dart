import 'package:equatable/equatable.dart';

class MonthlyReport extends Equatable {
  const MonthlyReport({
    required this.mes,
    required this.totalAtendimentos,
    required this.faturamento,
  });

  final DateTime mes;
  final int totalAtendimentos;
  final double faturamento;

  @override
  List<Object?> get props => [mes, totalAtendimentos, faturamento];
}
