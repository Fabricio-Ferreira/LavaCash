import 'package:equatable/equatable.dart';

import 'client.dart';

class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.placa,
    required this.clienteId,
    this.client,
  });

  final String id;
  final String placa;
  final String clienteId;
  final Client? client;

  @override
  List<Object?> get props => [id, placa, clienteId, client];
}
