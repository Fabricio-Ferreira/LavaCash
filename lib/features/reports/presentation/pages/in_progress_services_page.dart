import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lava_cash/domain/entities/service_status.dart';
import 'package:lava_cash/domain/entities/service_summary.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import '../controllers/report_controller.dart';
import '../widgets/service_summary_tile.dart';

/// All service records with status em andamento.
class InProgressServicesPage extends GetView<ReportController> {
  final ServiceStatus? status;
  const InProgressServicesPage({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final bool isLoading = controller.isInProgressLoading.value;
      final String err = controller.inProgressError.value;
      final List<ServiceSummary> servicesList =
          status == null
              ? controller.inProgressServices.toList()
              : controller.inProgressServices
                  .where((ServiceSummary summary) => summary.status == status)
                  .toList();
      return ThemedRefreshIndicator(
        onRefresh: () async {
          await controller.loadInProgressServices();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: <Widget>[
            if (err.isNotEmpty && servicesList.isEmpty && !isLoading)
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
            if (isLoading && servicesList.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!isLoading && servicesList.isEmpty && err.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Nenhum atendimento em andamento.',
                    style: textTheme.bodyLarge,
                  ),
                ),
              ),
            if (servicesList.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList.separated(
                  itemCount: servicesList.length,
                  separatorBuilder:
                      (_, __) => Divider(
                        height: 1,
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      ),
                  itemBuilder: (BuildContext context, int index) {
                    return ServiceSummaryTile(summary: servicesList[index]);
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// Shell with [AppBar] for [AppRoutes.inProgressServices].
class InProgressServicesRoutePage extends StatelessWidget {
  final ServiceStatus? status;
  const InProgressServicesRoutePage({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atendimentos do dia')),
      body: InProgressServicesPage(status: status),
    );
  }
}
