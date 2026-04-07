import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import '../controllers/report_controller.dart';
import '../models/daily_report_state.dart';
import '../widgets/daily_attendimentos_placeholder.dart';
import '../../../../shared/widgets/elite_hero_card.dart';
import '../../../../shared/widgets/payment_list_card.dart';
import '../widgets/daily_report_day_header.dart';
import '../widgets/dashboard_atendimentos_section.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/dashboard_stat_grid.dart';

/// Stitch "Relatório Diário — Nível Elite Final" layout.
class DailyReportTab extends GetView<ReportController> {
  const DailyReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final DailyReportState daily = DailyReportState.fromController(
        controller,
      );
      final String errorMessage = controller.errorMessage.value;
      final double ticketMedio =
          daily.totalCarros > 0 ? daily.totalRecebido / daily.totalCarros : 0;
      return ThemedRefreshIndicator(
        onRefresh: () async {
          await controller.loadDaily();
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final double pad = c.maxWidth > 600 ? 24 : 16;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
              children: [
                const DailyReportDayHeader(),
                if (errorMessage.isNotEmpty &&
                    !daily.isLoading &&
                    controller.dailyReport.value == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SelectableText.rich(
                      TextSpan(
                        text: errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                EliteHeroCard.dailyReport(
                  isLoading: daily.isLoading,
                  totalRecebido: daily.totalRecebido,
                ),
                const SizedBox(height: 16),
                DashboardStatGrid(
                  children: <Widget>[
                    DashboardStatCard(
                      icon: Icons.directions_car_outlined,
                      iconColor: AppColors.primary,
                      label: 'CARROS',
                      value: daily.isLoading ? '—' : '${daily.totalCarros}',
                    ),
                    DashboardStatCard(
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.primary,
                      label: 'TICKET MÉDIO',
                      value:
                          daily.isLoading
                              ? '—'
                              : AppFormatters.formatCurrency(ticketMedio),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Formas de Pagamento',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                PaymentListCard(
                  entries: daily.paymentEntries,
                  isLoading: daily.isLoading,
                ),
                const SizedBox(height: 24),
                if (controller.todayServices.isNotEmpty) ...[
                  DashboardAtendimentosSection(onVerTodos: _openTodayServices),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Atendimentos do dia',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const DailyAttendimentosPlaceholder(),
                ],
              ],
            );
          },
        ),
      );
    });
  }

  void _openTodayServices() {
    controller.loadInProgressServices();
    Get.toNamed<void>(AppRoutes.inProgressServices);
  }
}
