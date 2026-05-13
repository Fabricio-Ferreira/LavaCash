import 'package:flutter/material.dart';

import 'package:lava_cash/app/theme/app_colors.dart';

/// Full-width bottom call-to-action (gradient pill + shadow), matching
/// [NovoAtendimentoPage] primary action styling.
class GradientBottomCta extends StatelessWidget {
  const GradientBottomCta({
    super.key,
    required this.isEnabled,
    required this.onPressed,
    required this.label,
    this.icon = Icons.play_circle_filled,
    this.iconSize = 28,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 12, 24, 8),
  });

  final bool isEnabled;
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final double iconSize;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      opacity: isEnabled ? 1 : 0.45,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        scale: isEnabled ? 1 : 0.98,
        child: Container(
          width: double.infinity,
          padding: contentPadding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[
                AppColors.surface,
                AppColors.surface.withValues(alpha: 0),
              ],
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: <Color>[AppColors.primary, AppColors.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: isEnabled ? onPressed : null,
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(icon, color: Colors.white, size: iconSize),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
