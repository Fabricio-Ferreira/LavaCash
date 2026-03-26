import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';

abstract class AppSnackbar {
  static const Duration _defaultDuration = Duration(seconds: 3);
  static const double _borderRadius = 12;

  static void showSuccess(String message, {String? title}) {
    _show(
      title: title ?? 'Parabéns!',
      message: message,
      backgroundColor: AppColors.primary,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showError(String message, {String? title}) {
    _show(
      title: title ?? 'Ops!',
      message: message,
      backgroundColor: AppColors.tertiary,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showInfo(String message, {String? title}) {
    _show(
      title: title ?? 'Atenção',
      message: message,
      backgroundColor: AppColors.onSurfaceVariant,
      icon: Icons.info_outline_rounded,
    );
  }

  static void showWarning(String message, {String? title}) {
    _show(
      title: title ?? 'Atenção',
      message: message,
      backgroundColor: const Color(0xFFB45309),
      icon: Icons.warning_amber_rounded,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = _defaultDuration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: _borderRadius,
      icon: Icon(icon, color: Colors.white, size: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
