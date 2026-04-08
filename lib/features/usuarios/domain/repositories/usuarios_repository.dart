import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../entities/empresa_convite_pendente.dart';
import '../entities/empresa_usuario.dart';

abstract class UsuariosRepository {
  Future<Either<Failure, List<EmpresaUsuario>>> listUsuarios(String empresaId);

  /// Pending convites (`claimed_at` null). RLS allows only admin; operador gets
  /// empty or should not call — callers gate by role.
  Future<Either<Failure, List<EmpresaConvitePendente>>> listConvitesPendentes(
    String empresaId,
  );

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
