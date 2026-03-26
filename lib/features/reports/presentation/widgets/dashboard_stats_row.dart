import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'dashboard_stat_card.dart';

class DashboardStatsRow extends StatelessWidget {
  const DashboardStatsRow({
    super.key,
    required this.cars,
    required this.inProgress,
    this.onInProgressTap,
  });

  final int cars;
  final int inProgress;
  final VoidCallback? onInProgressTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final bool narrow = c.maxWidth < 340;
        final double gap = narrow ? 10 : 16;
        return Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                icon: Icons.directions_car_outlined,
                iconColor: AppColors.primary,
                label: 'CARROS ATENDIDOS',
                value: '$cars',
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: DashboardStatCard(
                icon: Icons.sync,
                iconColor: AppColors.secondary,
                label: 'EM ANDAMENTO',
                value: '$inProgress',
                onTap: onInProgressTap,
              ),
            ),
          ],
        );
      },
    );
  }
}
