import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/empresa_usuario.dart';

class EmpresaUsuarioModel {
  const EmpresaUsuarioModel({
    required this.id,
    required this.empresaId,
    required this.userId,
    required this.role,
    required this.createdAt,
    this.displayName,
    this.userEmail,
  });

  factory EmpresaUsuarioModel.fromJson(Map<String, dynamic> json) {
    return EmpresaUsuarioModel(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      userId: json['user_id'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'operador'),
      createdAt: DateTime.parse(json['created_at'] as String),
      displayName: json['display_name'] as String?,
      userEmail: json['user_email'] as String?,
    );
  }

  final String id;
  final String empresaId;
  final String userId;
  final UserRole role;
  final DateTime createdAt;
  final String? displayName;
  final String? userEmail;

  EmpresaUsuario toDomain() {
    return EmpresaUsuario(
      id: id,
      empresaId: empresaId,
      userId: userId,
      role: role,
      createdAt: createdAt,
      displayName: displayName,
      userEmail: userEmail,
    );
  }
}
