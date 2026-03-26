import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

class ClientResultCard extends StatelessWidget {
  const ClientResultCard({
    super.key,
    required this.clientName,
    required this.plateFormatted,
    required this.isSelected,
    required this.onTap,
  });

  final String clientName;
  final String plateFormatted;
  final bool isSelected;
  final VoidCallback onTap;

  static String initialsFromName(String name) {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      final String p = parts[0];
      if (p.length >= 2) {
        return p.substring(0, 2).toUpperCase();
      }
      return p.substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  static Color avatarBackgroundForName(String name) {
    const List<Color> palette = <Color>[
      Color(0x4D6BFF8F),
      Color(0x4DFFD9DE),
      Color(0x4D7FFC97),
    ];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return palette[hash.abs() % palette.length];
  }

  static Color avatarForegroundForName(String name) {
    const List<Color> palette = <Color>[
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.primary,
    ];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return palette[hash.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final String initials = initialsFromName(clientName);
    final Color bg = avatarBackgroundForName(clientName);
    final Color fg = avatarForegroundForName(clientName);
    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : AppColors.outlineVariant.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 24,
                backgroundColor: bg,
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      clientName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.directions_car,
                          size: 16,
                          color: AppColors.outline,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          plateFormatted,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontFamily: 'monospace',
                            letterSpacing: 1.2,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color:
                    isSelected ? AppColors.primary : AppColors.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
