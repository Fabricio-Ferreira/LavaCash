enum UserRole {
  admin,
  operador;

  static UserRole fromString(String value) {
    return switch (value) {
      'admin' => UserRole.admin,
      'operador' => UserRole.operador,
      _ => UserRole.operador,
    };
  }

  bool get isAdmin => this == UserRole.admin;

  String get label => switch (this) {
    UserRole.admin => 'Admin',
    UserRole.operador => 'Operador',
  };
}
