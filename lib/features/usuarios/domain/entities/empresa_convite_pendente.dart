import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_role.dart';

class EmpresaConvitePendente extends Equatable {
  const EmpresaConvitePendente({
    required this.id,
    required this.empresaId,
    required this.activationCode,
    required this.role,
    this.membroNome,
    required this.createdAt,
  });

  final String id;
  final String empresaId;
  final String activationCode;
  final UserRole role;
  final String? membroNome;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      <Object?>[id, empresaId, activationCode, role, membroNome, createdAt];
}
