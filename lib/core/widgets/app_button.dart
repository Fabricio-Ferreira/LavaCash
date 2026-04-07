import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final bool isInactive = isLoading || isDisabled;
    if (isSecondary) {
      return TextButton(
        onPressed: isInactive ? null : onPressed,
        child:
            isLoading
                ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Text(label),
      );
    }
    return ElevatedButton(
      onPressed: isInactive ? null : onPressed,
      child:
          isLoading
              ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : Text(label),
    );
  }
}

class AppGradientButton extends StatelessWidget {
  const AppGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.onDisabledPressed,
    this.trailingIcon,
    this.borderRadius = 16,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onDisabledPressed;
  final IconData? trailingIcon;
  final double borderRadius;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Widget button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap:
              isLoading
                  ? null
                  : isDisabled
                  ? onDisabledPressed
                  : onPressed,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Center(
              child:
                  isLoading
                      ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            label,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (trailingIcon != null) ...<Widget>[
                            const SizedBox(width: 8),
                            Icon(trailingIcon, color: Colors.white, size: 22),
                          ],
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
    if (isDisabled && !isLoading) {
      return Opacity(opacity: 0.45, child: button);
    }
    return button;
  }
}
