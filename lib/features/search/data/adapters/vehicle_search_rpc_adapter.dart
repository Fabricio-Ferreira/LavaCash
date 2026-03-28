import '../../../../data/models/client_model.dart';
import '../../../../domain/entities/vehicle.dart';
import '../../../../domain/entities/vehicle_with_client.dart';

/// Maps rows from Supabase RPC `search_vehicles_normalized` to [VehicleWithClient].
class VehicleSearchRpcAdapter {
  VehicleSearchRpcAdapter._();

  static VehicleWithClient toVehicleWithClient(Map<String, dynamic> row) {
    final ClientModel clientModel = ClientModel.fromJson(<String, dynamic>{
      'id': row['client_id'] as String,
      'nome': row['client_nome'] as String,
      'telefone': row['client_telefone'] as String,
    });
    final Vehicle vehicle = Vehicle(
      id: row['vehicle_id'] as String,
      placa: row['placa'] as String,
      clienteId: row['cliente_id'] as String,
      client: clientModel.toDomain(),
    );
    return VehicleWithClient(
      vehicle: vehicle,
      client: clientModel.toDomain(),
    );
  }
}
