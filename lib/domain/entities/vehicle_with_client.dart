import 'package:equatable/equatable.dart';

import 'client.dart';
import 'vehicle.dart';

class VehicleWithClient extends Equatable {
  const VehicleWithClient({
    required this.vehicle,
    required this.client,
  });

  final Vehicle vehicle;
  final Client client;

  @override
  List<Object?> get props => [vehicle, client];
}
