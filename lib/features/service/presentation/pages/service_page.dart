import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lava_cash/app/theme/app_colors.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../domain/entities/service_status.dart';
import '../../../reports/presentation/controllers/home_tab_controller.dart';
import '../../../reports/presentation/controllers/report_controller.dart';
import '../controllers/service_controller.dart';

class ServicePage extends GetView<ServiceController> {
  const ServicePage({super.key});

  void _navigateHomeAndRefresh() {
    Get.offAllNamed<void>(AppRoutes.home);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<HomeTabController>()) {
        Get.find<HomeTabController>().setTab(0);
      }
      if (Get.isRegistered<ReportController>()) {
        Get.find<ReportController>().loadDaily();
        Get.find<ReportController>().loadMonthly();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimento'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home_outlined, color: AppColors.primary),
            tooltip: 'Home',
            onPressed: _navigateHomeAndRefresh,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.errorMessage.value.isNotEmpty &&
              controller.vehicle.value == null) {
            return SelectableText.rich(
              TextSpan(
                text: controller.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final vehicle = controller.vehicle.value;
          if (vehicle == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                vehicle.client.nome,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Placa: ${vehicle.vehicle.placa}'),
              const SizedBox(height: 8),
              Text('Telefone: ${vehicle.client.telefone}'),
              const SizedBox(height: 24),
              Obx(
                () => Text(
                  controller.formattedElapsed,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${controller.serviceRecord.value?.status.labelPt ?? '—'}',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: controller.openWhatsApp,
                icon: const Icon(Icons.chat),
                label: const Text('WhatsApp'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Finalizar e pagar',
                onPressed: controller.goToPayment,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: controller.cancelService,
                child: const Text('Cancelar atendimento'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
