import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/features/service/presentation/controllers/service_controller.dart';

/// Inline notice when [ServiceController.attendanceLines] is empty (matches
/// catalog-first flow: payment requires at least one line).
class AttendanceAddServiceHintBanner extends GetView<ServiceController> {
  const AttendanceAddServiceHintBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      if (controller.isLinesLoading.value ||
          controller.attendanceLines.isNotEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.info_outline_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Para finalizar o atendimento, é preciso adicionar pelo '
                    'menos um serviço (sugestões rápidas ou o botão '
                    'Adicionar serviço).',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
