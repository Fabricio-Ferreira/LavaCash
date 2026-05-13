import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/formatters.dart';
import 'package:lava_cash/core/domain/entities/attendance_history_line.dart';
import 'package:lava_cash/core/domain/entities/vehicle_attendance_history_group.dart';

/// Expandable card for one vehicle’s attendance lines.
class AttendanceHistoryVehicleTile extends StatelessWidget {
  const AttendanceHistoryVehicleTile({super.key, required this.group});

  final VehicleAttendanceHistoryGroup group;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey<String>(group.veiculoId),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Text(
          '${group.placa} · ${group.clienteNome}',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${group.totalAtendimentos} atendimento(s)',
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        children: <Widget>[
          ...group.lines.map(
            (AttendanceHistoryLine line) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                AppFormatters.formatDateTime(line.horaEntradaLocal),
                style: textTheme.bodyMedium,
              ),
              subtitle:
                  line.servicosResumo != null &&
                      line.servicosResumo!.trim().isNotEmpty
                  ? Text(
                      line.servicosResumo!.trim(),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: Text(
                line.valor != null
                    ? AppFormatters.formatCurrency(line.valor!)
                    : '—',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
