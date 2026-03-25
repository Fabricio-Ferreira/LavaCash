import 'package:equatable/equatable.dart';

class BestWeekdayReport extends Equatable {
  const BestWeekdayReport({
    required this.diaSemana,
    required this.faturamento,
  });

  final String diaSemana;
  final double faturamento;

  @override
  List<Object?> get props => [diaSemana, faturamento];
}
