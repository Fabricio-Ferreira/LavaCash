import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_role.dart';

class EmpresaUsuario extends Equatable {
  const EmpresaUsuario({
    required this.id,
    required this.empresaId,
    required this.userId,
    required this.role,
    required this.createdAt,
    this.displayName,
    this.userEmail,
  });

  final String id;
  final String empresaId;
  final String userId;
  final UserRole role;
  final DateTime createdAt;
  /// Resolved on server (auth metadata or email local-part); may be null.
  final String? displayName;
  /// auth.users email; used when [displayName] is empty.
  final String? userEmail;

  /// Label for UI: nome preferencial, senão prefixo do email, senão [userId].
  String get displayLabel {
    final String? trimmedName = displayName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }
    final String? em = userEmail?.trim();
    if (em != null && em.isNotEmpty) {
      final int at = em.indexOf('@');
      if (at > 0) {
        return em.substring(0, at);
      }
      return em;
    }
    return userId;
  }

  EmpresaUsuario copyWith({
    UserRole? role,
    String? displayName,
    String? userEmail,
  }) {
    return EmpresaUsuario(
      id: id,
      empresaId: empresaId,
      userId: userId,
      role: role ?? this.role,
      createdAt: createdAt,
      displayName: displayName ?? this.displayName,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[id, empresaId, userId, role, createdAt, displayName, userEmail];
}
