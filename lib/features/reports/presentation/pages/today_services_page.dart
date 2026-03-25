import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import '../controllers/report_controller.dart';
import '../widgets/service_summary_tile.dart';

/// Full list of today's service records (same day as [ReportController] load).
class TodayServicesPage extends GetView<ReportController> {
  const TodayServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final bool isLoading = controller.isTodayServicesLoading.value;
      final String err = controller.todayServicesError.value;
      final int count = controller.todayServices.length;
      return ThemedRefreshIndicator(
        onRefresh: () async {
          await controller.loadTodayServices();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            if (err.isNotEmpty && count == 0 && !isLoading)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: SelectableText.rich(
                    TextSpan(
                      text: err,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            if (isLoading && count == 0)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!isLoading && count == 0 && err.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Nenhum atendimento hoje.',
                    style: textTheme.bodyLarge,
                  ),
                ),
              ),
            if (count > 0)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList.separated(
                  itemCount: count,
                  separatorBuilder:
                      (_, __) => Divider(
                        height: 1,
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      ),
                  itemBuilder: (BuildContext context, int index) {
                    return ServiceSummaryTile(
                      summary: controller.todayServices[index],
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}
