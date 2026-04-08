import 'package:flutter/material.dart';

import '../../../../../features/auth/domain/entities/user_role.dart';

class UsuarioActionMenu extends StatelessWidget {
  const UsuarioActionMenu({
    super.key,
    required this.role,
    required this.onChangeRole,
    required this.onRemove,
  });

  final UserRole role;
  final void Function(UserRole role) onChangeRole;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String value) {
        if (value == 'admin') {
          onChangeRole(UserRole.admin);
        }
        if (value == 'operador') {
          onChangeRole(UserRole.operador);
        }
        if (value == 'remove') {
          onRemove();
        }
      },
      itemBuilder: (_) => <PopupMenuEntry<String>>[
        if (role != UserRole.admin)
          const PopupMenuItem<String>(
            value: 'admin',
            child: Text('Promover a Admin'),
          ),
        if (role != UserRole.operador)
          const PopupMenuItem<String>(
            value: 'operador',
            child: Text('Rebaixar a Operador'),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'remove',
          child: Text(
            'Remover acesso',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
