import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../domain/entities/empresa_convite_pendente.dart';
import 'usuario_role_chip.dart';

class ConvitePendenteTile extends StatelessWidget {
  const ConvitePendenteTile({super.key, required this.convite});

  final EmpresaConvitePendente convite;

  @override
  Widget build(BuildContext context) {
    final String subtitle = convite.role.isAdmin
        ? 'Aguardando ativação'
        : (convite.membroNome?.trim().isNotEmpty == true
            ? convite.membroNome!.trim()
            : 'Operador — nome não informado');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: AppColors.surfaceContainer.withValues(alpha: 0.65),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceContainer,
          child: Icon(
            Icons.mail_outline,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        title: Text(
          convite.activationCode,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            UsuarioRoleChip(role: convite.role),
          ],
        ),
      ),
    );
  }
}
