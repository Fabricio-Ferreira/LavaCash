import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/update_info.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({
    super.key,
    required this.info,
    required this.onUpdatePressed,
  });

  final UpdateInfo info;
  final VoidCallback onUpdatePressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: !info.isMandatory,
      child: AlertDialog(
        title: Text(
          info.title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                info.message,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Versão: ${info.latestVersion} (${info.latestBuildNumber})',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (info.releaseNotes.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  'O que mudou:',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...info.releaseNotes.map(
                  (String note) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• $note',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: <Widget>[
          if (!info.isMandatory)
            TextButton(
              onPressed: () => Navigator.of(context).pop<void>(),
              child: const Text('Depois'),
            ),
          FilledButton(
            onPressed: onUpdatePressed,
            child: const Text('Atualizar agora'),
          ),
        ],
      ),
    );
  }
}
