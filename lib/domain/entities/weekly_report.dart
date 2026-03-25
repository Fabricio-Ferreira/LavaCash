import 'package:equatable/equatable.dart';

class WeeklyReport extends Equatable {
  const WeeklyReport({
    required this.semana,
    required this.totalAtendimentos,
    required this.faturamento,
  });

  /// Calendar week block within the month: 1–4.
  final int semana;
  final int totalAtendimentos;
  final double faturamento;

  @override
  List<Object?> get props => [semana, totalAtendimentos, faturamento];
}
