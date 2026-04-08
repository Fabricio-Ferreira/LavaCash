import 'package:equatable/equatable.dart';

import 'user_role.dart';

class UserSession extends Equatable {
  const UserSession({
    required this.userId,
    required this.email,
    this.role = UserRole.operador,
    this.empresaId,
  });

  final String userId;
  final String email;
  final UserRole role;
  final String? empresaId;

  UserSession copyWith({
    String? userId,
    String? email,
    UserRole? role,
    String? empresaId,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      empresaId: empresaId ?? this.empresaId,
    );
  }

  @override
  List<Object?> get props => <Object?>[userId, email, role, empresaId];
}
