import 'package:equatable/equatable.dart';

import 'service_status.dart';

class ServiceSummary extends Equatable {
  const ServiceSummary({
    required this.id,
    required this.veiculoId,
    required this.clienteNome,
    required this.placa,
    required this.horaEntrada,
    this.valor,
    required this.status,
  });

  final String id;
  final String veiculoId;
  final String clienteNome;
  final String placa;
  final DateTime horaEntrada;
  final double? valor;
  final ServiceStatus status;

  @override
  List<Object?> get props => [
    id,
    veiculoId,
    clienteNome,
    placa,
    horaEntrada,
    valor,
    status,
  ];
}
