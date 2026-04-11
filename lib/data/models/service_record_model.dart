import 'package:lava_cash/core/domain/entities/payment_method.dart';
import 'package:lava_cash/core/domain/entities/service_record.dart';
import 'package:lava_cash/core/domain/entities/service_status.dart';

class ServiceRecordModel {
  const ServiceRecordModel({
    required this.id,
    required this.veiculoId,
    required this.horaEntrada,
    this.horaSaida,
    this.duracaoMinutos,
    this.valor,
    this.nomeServico,
    this.observacao,
    this.formaPagamento,
    required this.status,
  });

  final String id;
  final String veiculoId;
  final DateTime horaEntrada;
  final DateTime? horaSaida;
  final int? duracaoMinutos;
  final double? valor;
  final String? nomeServico;
  final String? observacao;
  final String? formaPagamento;
  final String status;

  factory ServiceRecordModel.fromJson(Map<String, dynamic> json) {
    return ServiceRecordModel(
      id: json['id'] as String,
      veiculoId: json['veiculo_id'] as String,
      horaEntrada: DateTime.parse(json['hora_entrada'] as String),
      horaSaida:
          json['hora_saida'] == null
              ? null
              : DateTime.parse(json['hora_saida'] as String),
      duracaoMinutos: json['duracao_minutos'] as int?,
      valor: _parseDouble(json['valor']),
      nomeServico: json['nome_servico'] as String?,
      observacao: json['observacao'] as String?,
      formaPagamento: json['forma_pagamento'] as String?,
      status: json['status'] as String,
    );
  }

  static double? _parseDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  ServiceRecord toDomain() {
    return ServiceRecord(
      id: id,
      veiculoId: veiculoId,
      horaEntrada: horaEntrada,
      horaSaida: horaSaida,
      duracaoMinutos: duracaoMinutos,
      valor: valor,
      nomeServico: nomeServico,
      observacao: observacao,
      formaPagamento: PaymentMethodX.fromDb(formaPagamento),
      status: ServiceStatusX.fromDb(status) ?? ServiceStatus.emAndamento,
    );
  }
}
