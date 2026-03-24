import '../../domain/entities/vehicle.dart';
import 'client_model.dart';

class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.placa,
    required this.clienteId,
    this.clientes,
  });

  final String id;
  final String placa;
  final String clienteId;
  final ClientModel? clientes;

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      placa: json['placa'] as String,
      clienteId: json['cliente_id'] as String,
      clientes: _parseClient(json['clientes']),
    );
  }

  static ClientModel? _parseClient(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is List && raw.isNotEmpty) {
      return ClientModel.fromJson(raw.first as Map<String, dynamic>);
    }
    if (raw is Map<String, dynamic>) {
      return ClientModel.fromJson(raw);
    }
    return null;
  }

  Vehicle toDomain() {
    return Vehicle(
      id: id,
      placa: placa,
      clienteId: clienteId,
      client: clientes?.toDomain(),
    );
  }
}
