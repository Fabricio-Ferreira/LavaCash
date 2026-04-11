import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'dashboard_stat_card.dart';
import 'dashboard_stat_grid.dart';

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
        final double gap = narrow ? 6 : 8;
        return DashboardStatGrid(
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
          childAspectRatio: narrow ? 1.32 : 1.5,
          children: <Widget>[
            DashboardStatCard(
              icon: Icons.directions_car_outlined,
              iconColor: AppColors.primary,
              label: 'CARROS ATENDIDOS',
              value: '$cars',
            ),
            DashboardStatCard(
              icon: Icons.sync,
              iconColor: AppColors.secondary,
              label: 'EM ANDAMENTO',
              value: '$inProgress',
              onTap: onInProgressTap,
            ),
          ],
        );
      },
    );
  }
}
