import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../domain/entities/vehicle.dart';

abstract class RegistrationRepository {
  Future<Either<Failure, Vehicle>> registerClientAndVehicle({
    required String nome,
    required String telefone,
    required String placa,
  });
}
