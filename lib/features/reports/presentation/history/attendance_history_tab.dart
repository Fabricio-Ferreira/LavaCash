import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/plate_or_name_search_input_formatter.dart';
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
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              _AttendanceHistoryTopSliver(
                horizontalPadding: pad,
                textTheme: textTheme,
                controller: controller,
              ),
              _AttendanceHistoryErrorSliver(horizontalPadding: pad),
              _AttendanceHistoryLoadingSliver(horizontalPadding: pad),
              _AttendanceHistoryContentSliver(
                horizontalPadding: pad,
                bottomPadding: 120,
                textTheme: textTheme,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AttendanceHistoryTopSliver extends StatelessWidget {
  const _AttendanceHistoryTopSliver({
    required this.horizontalPadding,
    required this.textTheme,
    required this.controller,
  });

  final double horizontalPadding;
  final TextTheme textTheme;
  final AttendanceHistoryController controller;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          <Widget>[
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
              inputFormatters: <TextInputFormatter>[
                PlateOrNameSearchInputFormatter(),
              ],
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
          ],
        ),
      ),
    );
  }
}

/// Só reage a erro / loading vazio — não reconstrói a lista de veículos.
class _AttendanceHistoryErrorSliver extends GetView<AttendanceHistoryController> {
  const _AttendanceHistoryErrorSliver({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String err = controller.errorMessage.value;
      final bool loading = controller.isLoading.value;
      final bool empty = controller.groups.isEmpty;
      if (err.isEmpty || loading || !empty) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
        sliver: SliverToBoxAdapter(
          child: SelectableText.rich(
            TextSpan(
              text: err,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    });
  }
}

/// Indicador global de carga inicial — isolado da lista paginada.
class _AttendanceHistoryLoadingSliver
    extends GetView<AttendanceHistoryController> {
  const _AttendanceHistoryLoadingSliver({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isLoading.value) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    });
  }
}

/// Chips, lazy list de veículos e rodapé — só quando não está em loading inicial.
class _AttendanceHistoryContentSliver
    extends GetView<AttendanceHistoryController> {
  const _AttendanceHistoryContentSliver({
    required this.horizontalPadding,
    required this.bottomPadding,
    required this.textTheme,
  });

  final double horizontalPadding;
  final double bottomPadding;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      final List<VehicleAttendanceHistoryGroup> list =
          controller.groups.toList();
      final int totalAtt = list.fold<int>(
        0,
        (int a, VehicleAttendanceHistoryGroup g) => a + g.totalAtendimentos,
      );
      final int totalVehLoaded = list.length;
      final int? filterVehicleCount = controller.totalVehicles.value;
      final String vehiclesValue =
          '${filterVehicleCount ?? totalVehLoaded}';
      final int childCount =
          list.isEmpty ? 2 : 1 + list.length + 1;
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          bottomPadding,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 4),
                    Text(
                      'Ordem alfabética por cliente e placa; cada página '
                      'mostra os próximos veículos nessa ordem.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (list.isEmpty)
                      Text(
                        'Nenhum atendimento finalizado no período.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                );
              }
              if (list.isEmpty) {
                return const AttendanceHistoryPaginationFooter();
              }
              if (index <= list.length) {
                return AttendanceHistoryVehicleTile(
                  group: list[index - 1],
                );
              }
              return const AttendanceHistoryPaginationFooter();
            },
            childCount: childCount,
          ),
        ),
      );
    });
  }
}
