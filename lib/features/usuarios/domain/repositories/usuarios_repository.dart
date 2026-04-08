import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../entities/empresa_usuario.dart';

abstract class UsuariosRepository {
  Future<Either<Failure, List<EmpresaUsuario>>> listUsuarios(String empresaId);

  Future<Either<Failure, Unit>> updateRole({
    required String userId,
    required String empresaId,
    required UserRole role,
  });

  Future<Either<Failure, Unit>> removeUsuario({
    required String userId,
    required String empresaId,
  });

  Future<Either<Failure, Unit>> addConvite({
    required String empresaId,
    required String activationCode,
    required UserRole role,
    /// Required when [role] is operador; stored in `empresa_convites.membro_nome`.
    String? membroNome,
  });
}
