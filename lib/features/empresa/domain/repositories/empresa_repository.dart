import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/empresa.dart';

abstract class EmpresaRepository {
  Future<Either<Failure, Empresa?>> fetchOwn();

  Future<Either<Failure, Empresa?>> claimByActivationCode(
    String activationCode,
  );

  Future<Either<Failure, Empresa>> create({
    required String nome,
    required String telefone,
    required String activationCode,
  });
}
