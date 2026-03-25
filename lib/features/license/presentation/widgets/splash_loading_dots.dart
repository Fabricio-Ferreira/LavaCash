import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class SplashLoadingDots extends StatefulWidget {
  const SplashLoadingDots({super.key});

  @override
  State<SplashLoadingDots> createState() => _SplashLoadingDotsState();
}

class _SplashLoadingDotsState extends State<SplashLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotOpacity(int index) {
    final double progress = (_controller.value + (index * 0.18)) % 1.0;
    if (progress < 0.33) {
      return 0.35;
    }
    if (progress < 0.66) {
      return 0.65;
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (int index) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: _dotOpacity(index)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
