import 'package:equatable/equatable.dart';

import 'payment_method.dart';
import 'service_status.dart';

class ServiceRecord extends Equatable {
  const ServiceRecord({
    required this.id,
    required this.veiculoId,
    required this.horaEntrada,
    this.horaSaida,
    this.duracaoMinutos,
    this.valor,
    this.formaPagamento,
    required this.status,
  });

  final String id;
  final String veiculoId;
  final DateTime horaEntrada;
  final DateTime? horaSaida;
  final int? duracaoMinutos;
  final double? valor;
  final PaymentMethod? formaPagamento;
  final ServiceStatus status;

  @override
  List<Object?> get props => [
    id,
    veiculoId,
    horaEntrada,
    horaSaida,
    duracaoMinutos,
    valor,
    formaPagamento,
    status,
  ];
}
