import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/empresa_convite_pendente.dart';

class EmpresaConvitePendenteModel {
  const EmpresaConvitePendenteModel({
    required this.id,
    required this.empresaId,
    required this.activationCode,
    required this.role,
    this.membroNome,
    required this.createdAt,
  });

  factory EmpresaConvitePendenteModel.fromJson(Map<String, dynamic> json) {
    return EmpresaConvitePendenteModel(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      activationCode: json['activation_code'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'operador'),
      membroNome: json['membro_nome'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String empresaId;
  final String activationCode;
  final UserRole role;
  final String? membroNome;
  final DateTime createdAt;

  EmpresaConvitePendente toDomain() {
    return EmpresaConvitePendente(
      id: id,
      empresaId: empresaId,
      activationCode: activationCode,
      role: role,
      membroNome: membroNome,
      createdAt: createdAt,
    );
  }
}
