import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/utils/dashed_rounded_rect_painter.dart';
import 'package:lava_cash/features/service/presentation/controllers/service_controller.dart';

/// Dashed-outline control to open the service catalog picker flow.
class DashedAddServiceButton extends GetView<ServiceController> {
  const DashedAddServiceButton({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return CustomPaint(
      painter: DashedRoundedRectPainter(
        color: AppColors.outlineVariant.withValues(alpha: 0.8),
        radius: 16,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.openServiceCatalogSelect(),
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: AppColors.primary.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add_circle_outline, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'Adicionar serviço',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
