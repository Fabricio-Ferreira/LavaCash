import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/license_controller.dart';
import '../widgets/splash_loading_dots.dart';
import '../widgets/splash_logo.dart';
import '../widgets/splash_palette.dart';
import '../widgets/splash_watermark.dart';

class SplashPage extends GetView<LicenseController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: SplashPalette.background,
      body: Stack(
        children: [
          const SplashWatermark(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const SplashLogo(),
                  const SizedBox(height: 24),
                  Text(
                    'LavaCash',
                    style: textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: SplashPalette.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Seu faturamento, na palma da mão.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: SplashPalette.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(flex: 1),
                  Obx(
                    () => controller.isChecking.value
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SplashLoadingDots(),
                              const SizedBox(height: 18),
                              Text(
                                'Sincronizando Fluxo',
                                style: textTheme.labelMedium?.copyWith(
                                  color: SplashPalette.textTertiary,
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
