import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Gradient container + optional watermark used by all elite hero variants.
class EliteHeroShell extends StatelessWidget {
  const EliteHeroShell({
    super.key,
    required this.child,
    this.watermarkText,
    this.watermarkFontSize = 88,
    this.watermarkRight = -8,
    this.watermarkTop = -28,
  });

  static const double borderRadius = 24;
  static const List<Color> gradientColors = <Color>[
    Color(0xFF003816),
    Color(0xFF006E2F),
    AppColors.primary,
  ];

  final Widget child;
  final String? watermarkText;
  final double watermarkFontSize;
  final double watermarkRight;
  final double watermarkTop;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        if (watermarkText != null)
          Positioned(
            right: watermarkRight,
            top: watermarkTop,
            child: Text(
              watermarkText!,
              style: TextStyle(
                fontSize: watermarkFontSize,
                fontWeight: FontWeight.w900,
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.2,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ],
    );
  }
}
