import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lava_cash/app/theme/app_colors.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../dashboard/presentation/controllers/home_tab_controller.dart';
import 'package:lava_cash/features/reports/presentation/controllers/report_controller.dart';
import '../controllers/service_controller.dart';
import 'widgets/service_attendance_sections.dart';
import 'widgets/service_client_header.dart';
import 'widgets/service_timer_section.dart';

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
      backgroundColor: AppColors.surface,
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
      body: Obx(() {
        if (controller.errorMessage.value.isNotEmpty &&
            controller.vehicle.value == null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText.rich(
              TextSpan(
                text: controller.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        final vehicle = controller.vehicle.value;
        if (vehicle == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ServiceClientHeader(
                clientName: vehicle.client.nome,
                plateFormatted: AppFormatters.formatPlate(
                  vehicle.vehicle.placa,
                ),
                phone: vehicle.client.telefone,
              ),
              const SizedBox(height: 28),
              Obx(() {
                final int tick = controller.elapsedSeconds.value;
                final record = controller.serviceRecord.value;
                if (record == null) {
                  return const SizedBox.shrink();
                }
                return ServiceTimerSection(
                  elapsedHoursMinutes: AppFormatters.formatElapsedHoursMinutes(
                    tick,
                  ),
                  durationFull: AppFormatters.formatDurationFromSeconds(tick),
                  entryTime: record.horaEntrada,
                );
              }),
              const SizedBox(height: 28),
              SelectedServicesSection(),
              QuickSuggestionsChipsSection(),
              const SizedBox(height: 20),
              DashedAddServiceButton(),
              const SizedBox(height: 20),
              Obx(() {
                final double total = controller.attendanceTotalValor;
                if (total <= 0) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Total do Atendimento',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        AppFormatters.formatCurrency(total),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: controller.openWhatsApp,
                icon: const Icon(Icons.chat),
                label: const Text('WhatsApp'),
              ),
              const SizedBox(height: 12),
              Obx(
                () => AppButton(
                  label: 'Finalizar e pagar',
                  onPressed:
                      controller.paymentFormValid.value
                          ? controller.goToPayment
                          : null,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: controller.cancelService,
                child: const Text(
                  'Cancelar atendimento',
                  style: TextStyle(color: AppColors.tertiary),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
