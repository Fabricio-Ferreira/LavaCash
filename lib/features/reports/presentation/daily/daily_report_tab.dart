import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/home_tab_scroll_padding.dart';
import 'package:lava_cash/core/domain/entities/service_breakdown_row.dart';
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
    return ThemedRefreshIndicator(
      onRefresh: () async {
        await controller.loadDaily();
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double pad = c.maxWidth > 600 ? 20 : 14;
          final double bottomInset = homeTabListBottomPadding(context);
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(pad, 4, pad, 0),
                sliver: const SliverToBoxAdapter(
                  child: DailyReportDayHeader(),
                ),
              ),
              _DailyErrorSliver(horizontalPadding: pad),
              _DailySummarySliver(
                horizontalPadding: pad,
                textTheme: textTheme,
              ),
              _DailyAttendimentosBlockSliver(
                horizontalPadding: pad,
                textTheme: textTheme,
                bottomPadding: bottomInset,
                onVerTodos: _openTodayServices,
              ),
            ],
          );
        },
      ),
    );
  }

  void _openTodayServices() {
    controller.loadInProgressServices();
    Get.toNamed<void>(AppRoutes.inProgressServices);
  }
}

class _DailyErrorSliver extends GetView<ReportController> {
  const _DailyErrorSliver({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String errorMessage = controller.errorMessage.value;
      final DailyReportState daily = DailyReportState.fromController(
        controller,
      );
      if (errorMessage.isEmpty ||
          daily.isLoading ||
          controller.dailyReport.value != null) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 8),
        sliver: SliverToBoxAdapter(
          child: SelectableText.rich(
            TextSpan(
              text: errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    });
  }
}

/// Receita, stats e pagamentos: não reconstrói quando só [todayServices] muda.
class _DailySummarySliver extends GetView<ReportController> {
  const _DailySummarySliver({
    required this.horizontalPadding,
    required this.textTheme,
  });

  final double horizontalPadding;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final DailyReportState daily = DailyReportState.fromController(
        controller,
      );
      final double ticketMedio =
          daily.totalCarros > 0 ? daily.totalRecebido / daily.totalCarros : 0;
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                        value: daily.isLoading
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
              Obx(() {
                final String bErr = controller.dailyServiceBreakdownError.value;
                final List<ServiceBreakdownRow> rows =
                    controller.dailyServiceBreakdown.toList();
                if (daily.isLoading) {
                  return const SizedBox.shrink();
                }
                if (bErr.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SelectableText.rich(
                      TextSpan(
                        text: bErr,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                if (rows.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Por serviço',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...rows.map((ServiceBreakdownRow r) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          r.nomeExibicao,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('Qtd: ${r.quantidade}'),
                        trailing: Text(
                          AppFormatters.formatCurrency(r.faturamento),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
              const SizedBox(height: 20),
              DashboardDespesasSection(daily: daily),
            ],
          ),
        ),
      );
    });
  }
}

class _DailyAttendimentosBlockSliver extends GetView<ReportController> {
  const _DailyAttendimentosBlockSliver({
    required this.horizontalPadding,
    required this.textTheme,
    required this.bottomPadding,
    required this.onVerTodos,
  });

  final double horizontalPadding;
  final TextTheme textTheme;
  final double bottomPadding;
  final VoidCallback onVerTodos;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasServices = controller.todayServices.isNotEmpty;
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          bottomPadding,
        ),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              if (hasServices)
                DashboardAtendimentosSection(onVerTodos: onVerTodos)
              else ...<Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
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
          ),
        ),
      );
    });
  }
}
