import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/service_record.dart';
import '../../../../domain/entities/vehicle_with_client.dart';

abstract class ServiceRepository {
  Future<Either<Failure, VehicleWithClient>> getVehicleWithClient(
    String vehicleId,
  );

  Future<Either<Failure, ServiceRecord>> startService(String vehicleId);

  Future<Either<Failure, Unit>> cancelService(String serviceId);
}
