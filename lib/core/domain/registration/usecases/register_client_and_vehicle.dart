import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/vehicle.dart';
import '../repositories/registration_repository.dart';

class RegisterClientAndVehicle {
  RegisterClientAndVehicle({required RegistrationRepository repository})
    : _repository = repository;

  final RegistrationRepository _repository;

  Future<Either<Failure, Vehicle>> call({
    required String nome,
    required String telefone,
    required String placa,
  }) {
    return _repository.registerClientAndVehicle(
      nome: nome,
      telefone: telefone,
      placa: placa,
    );
  }
}
