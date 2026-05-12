import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/vehicle.dart';

abstract class RegistrationRepository {
  Future<Either<Failure, Vehicle>> registerClientAndVehicle({
    required String nome,
    required String telefone,
    required String placa,
  });

  Future<Either<Failure, Vehicle>> updateClientAndVehicle({
    required String clienteId,
    required String veiculoId,
    required String nome,
    required String telefone,
    required String placa,
  });
}
