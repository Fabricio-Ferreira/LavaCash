import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/license_controller.dart';

/// Local palette for splash visuals (extends brand without bloating [AppColors]).
abstract class _SplashPalette {
  static const Color background = AppColors.surface;
  static const Color textPrimary = AppColors.onSurface;
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color primaryDark = Color(0xFF047857);
  static const Color shadow = Color(0x33006B2C);
  static const Color textOnDark = Colors.white;
}

abstract class _SplashAssets {
  static const String logo = 'assets/images/logo.svg';
}

class SplashPage extends GetView<LicenseController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _SplashPalette.background,
      body: Stack(
        children: [
          const _SplashWatermark(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const _SplashLogo(),
                  const SizedBox(height: 24),
                  Text(
                    'LavaCash',
                    style: textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _SplashPalette.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Seu faturamento, na palma da mão.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: _SplashPalette.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(flex: 1),
                  Obx(
                    () => controller.isChecking.value
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _LoadingDots(),
                              const SizedBox(height: 18),
                              Text(
                                'Sincronizando Fluxo',
                                style: textTheme.labelMedium?.copyWith(
                                  color: _SplashPalette.textTertiary,
                                  letterSpacing: 2.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: _SplashPalette.shadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SvgPicture.asset(
          _SplashAssets.logo,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          semanticsLabel: 'LavaCash logo',
        ),
      ),
    );
  }
}

class _SplashWatermark extends StatelessWidget {
  const _SplashWatermark();

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

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
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
