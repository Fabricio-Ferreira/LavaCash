import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class SplashWatermark extends StatelessWidget {
  const SplashWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Transform.rotate(
            angle: -25 * math.pi / 180,
            child: Text(
              '\$',
              style: TextStyle(
                fontSize: 400,
                height: 1,
                fontWeight: FontWeight.w900,
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
