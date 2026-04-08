import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../features/auth/domain/entities/user_role.dart';
import '../../../domain/entities/empresa_usuario.dart';
import 'usuario_action_menu.dart';
import 'usuario_role_chip.dart';

class UsuarioListTile extends StatelessWidget {
  const UsuarioListTile({
    super.key,
    required this.usuario,
    required this.isCurrentUser,
    required this.onChangeRole,
    required this.onRemove,
  });

  final EmpresaUsuario usuario;
  final bool isCurrentUser;
  final void Function(UserRole role) onChangeRole;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = usuario.role.isAdmin;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        dense: true,
        leading: CircleAvatar(
          backgroundColor:
              isAdmin ? AppColors.primaryContainer : AppColors.surfaceContainer,
          child: Icon(
            isAdmin ? Icons.manage_accounts : Icons.person_outline,
            color: isAdmin ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
        title: Text(
          usuario.displayLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [SizedBox(height: 4), UsuarioRoleChip(role: usuario.role)],
        ),
        trailing:
            isCurrentUser
                ? null
                : UsuarioActionMenu(
                  role: usuario.role,
                  onChangeRole: onChangeRole,
                  onRemove: onRemove,
                ),
      ),
    );
  }
}
