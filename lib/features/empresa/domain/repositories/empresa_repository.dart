import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_role.dart';
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

  /// Accepts a pending convite for [activationCode] and returns the empresa.
  Future<Either<Failure, Empresa?>> acceptConvite(String activationCode);

  /// Fetches the current user's role from empresa_usuarios.
  Future<Either<Failure, UserRole?>> fetchMyRole();

  /// Registers the current user as [role] in [empresaId] after claim/create.
  Future<Either<Failure, Unit>> registerUserInEmpresa({
    required String empresaId,
    required UserRole role,
  });

  /// Comercial package: links [auth.uid] to pre-created empresa (CRM bridge).
  Future<Either<Failure, Unit>> joinEmpresaAsDevice(String empresaId);
}
