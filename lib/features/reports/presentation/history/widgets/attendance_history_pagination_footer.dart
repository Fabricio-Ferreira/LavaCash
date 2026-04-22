import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../controllers/attendance_history_controller.dart';

/// "Carregar mais" + feedback ao chegar no fim da paginação por veículo.
class AttendanceHistoryPaginationFooter
    extends GetView<AttendanceHistoryController> {
  const AttendanceHistoryPaginationFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final int loaded = controller.groups.length;
      if (loaded == 0) {
        return const SizedBox.shrink();
      }
      if (controller.canLoadMore) {
        final bool loadingMore = controller.isLoadingMore.value;
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (loadingMore) ...<Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    color: AppColors.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Text(
                    'Carregando mais veículos…',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              Center(
                child: FilledButton.tonal(
                  onPressed: loadingMore ? null : () => controller.loadMore(),
                  child: loadingMore
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Aguarde…',
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Carregar mais '
                          '(${AttendanceHistoryController.vehiclePageSize} '
                          'veículos)',
                        ),
                ),
              ),
            ],
          ),
        );
      }
      final int? cap = controller.totalVehicles.value;
      final int pageSize = AttendanceHistoryController.vehiclePageSize;
      if (cap != null &&
          cap > pageSize &&
          loaded >= cap) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    size: 22,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Fim da lista: todos os $cap veículos deste filtro '
                      'já estão exibidos.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
