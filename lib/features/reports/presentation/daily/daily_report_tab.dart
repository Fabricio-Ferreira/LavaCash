import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import '../../../../shared/widgets/dashboard_stats/dashboard_stat_card.dart';
import '../../../../shared/widgets/dashboard_stats/dashboard_stat_grid.dart';
import '../../../../shared/widgets/elite_hero_card.dart';
import '../../../../shared/widgets/payment_list_card.dart';
import '../../../dashboard/presentation/widgets/dashboard_atendimentos_section.dart';
import '../../../dashboard/presentation/widgets/dashboard_despesas_section.dart';
import '../controllers/report_controller.dart';
import '../models/daily_report_state.dart';
import 'widgets/daily_attendimentos_placeholder.dart';
import 'widgets/daily_report_day_header.dart';

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
            final double pad = c.maxWidth > 600 ? 20 : 14;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(pad, 4, pad, 72),
              children: [
                const DailyReportDayHeader(),
                if (errorMessage.isNotEmpty &&
                    !daily.isLoading &&
                    controller.dailyReport.value == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SelectableText.rich(
                      TextSpan(
                        text: errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                EliteHeroCard.dailyReport(
                  isLoading: daily.isLoading,
                  totalRecebido: daily.totalRecebido,
                  totalDespesas: daily.totalDespesas,
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool narrow = constraints.maxWidth < 340;
                    final double gap = narrow ? 6 : 8;
                    return DashboardStatGrid(
                      crossAxisSpacing: gap,
                      mainAxisSpacing: gap,
                      childAspectRatio: narrow ? 1.32 : 1.5,
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
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Formas de Pagamento',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                PaymentListCard(
                  entries: daily.paymentEntries,
                  isLoading: daily.isLoading,
                ),
                const SizedBox(height: 20),
                DashboardDespesasSection(daily: daily),
                const SizedBox(height: 20),
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
                  const SizedBox(height: 6),
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
