import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/domain/entities/attendance_service_line.dart';
import 'package:lava_cash/core/utils/formatters.dart';
import 'package:lava_cash/features/service/presentation/controllers/service_controller.dart';

/// One selected service row on the attendance screen.
class AttendanceServiceLineCard extends GetView<ServiceController> {
  const AttendanceServiceLineCard({super.key, required this.line});

  final AttendanceServiceLine line;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_car_wash_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    line.nome,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (line.observacao != null &&
                      line.observacao!.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      line.observacao!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  AppFormatters.formatCurrency(line.valor),
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.all(4),
                    minimumSize: const Size(32, 32),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.close, size: 22),
                  color: AppColors.onSurfaceVariant,
                  onPressed: () => controller.removeLine(line),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
