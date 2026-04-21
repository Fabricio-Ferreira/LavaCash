import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import 'package:lava_cash/core/domain/entities/vehicle_attendance_history_group.dart';
import '../controllers/attendance_history_controller.dart';
import 'widgets/attendance_history_pagination_footer.dart';
import 'widgets/attendance_history_period_header.dart';
import 'widgets/attendance_history_summary_chip.dart';
import 'widgets/attendance_history_vehicle_tile.dart';

/// Histórico de atendimentos finalizados com filtro por cliente/placa e período.
class AttendanceHistoryTab extends GetView<AttendanceHistoryController> {
  const AttendanceHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ThemedRefreshIndicator(
      onRefresh: () async {
        await controller.load();
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double pad = c.maxWidth > 600 ? 24 : 16;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
            children: <Widget>[
              const AttendanceHistoryPeriodHeader(),
              const SizedBox(height: 16),
              Text(
                'Cliente ou placa',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Nome do cliente ou placa…',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  prefixIcon: const Icon(Icons.search, size: 22),
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: controller.onSearchChanged,
              ),
              Obx(() {
                final bool loading = controller.isLoading.value;
                final String err = controller.errorMessage.value;
                final List<VehicleAttendanceHistoryGroup> list =
                    controller.groups.toList();
                final int totalAtt = list.fold<int>(
                  0,
                  (int a, VehicleAttendanceHistoryGroup g) =>
                      a + g.totalAtendimentos,
                );
                final int totalVehLoaded = list.length;
                final int? cap = controller.totalVehicles.value;
                final String vehiclesValue =
                    cap != null ? '$totalVehLoaded / $cap' : '$totalVehLoaded';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (err.isNotEmpty && !loading && list.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SelectableText.rich(
                          TextSpan(
                            text: err,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...<Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AttendanceHistorySummaryChip(
                              label: 'Atendimentos',
                              value: '$totalAtt',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AttendanceHistorySummaryChip(
                              label: 'Veículos',
                              value: vehiclesValue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Por veículo',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (list.isEmpty)
                        Text(
                          'Nenhum atendimento finalizado no período.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        )
                      else
                        ...list.map(
                          (VehicleAttendanceHistoryGroup g) =>
                              AttendanceHistoryVehicleTile(group: g),
                        ),
                      const AttendanceHistoryPaginationFooter(),
                    ],
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
