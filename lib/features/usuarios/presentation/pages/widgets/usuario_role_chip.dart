import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../features/auth/domain/entities/user_role.dart';

class UsuarioRoleChip extends StatelessWidget {
  const UsuarioRoleChip({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = role.isAdmin;
    return Chip(
      label: Text(
        role.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isAdmin ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
      backgroundColor:
          isAdmin
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceContainerLow,
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
