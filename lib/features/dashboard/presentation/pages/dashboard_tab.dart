import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lava_cash/core/domain/entities/service_status.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import 'package:lava_cash/features/reports/presentation/models/daily_report_state.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../shared/widgets/dashboard_stats/dashboard_stats_row.dart';
import '../../../../shared/widgets/elite_hero_card.dart';
import '../widgets/dashboard_atendimentos_section.dart';
import '../widgets/dashboard_despesas_section.dart';
import '../widgets/dashboard_greeting_header.dart';
import '../widgets/dashboard_monthly_performance_section.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_recebimento_section.dart';

/// Stitch "Dashboard — Versão Elite Suprema" layout with live report data.
/// When [AppConstants.useMockReportData] is true, data comes from
/// `ReportRepositoryMock` (see `HomeBinding`).
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimations = List<Animation<double>>.generate(8, (int i) {
      final double start = (i * 0.08).clamp(0.0, 1.0);
      final double endUncapped = 0.55 + i * 0.07;
      final double end = endUncapped.clamp(start + 0.02, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DashboardController>().loadInitialReportData();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboard = Get.find<DashboardController>();
    return Obx(() {
      final DailyReportState daily = DailyReportState.fromController(
        dashboard.reportController,
      );
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxW = constraints.maxWidth;
          final double horizontalPad = maxW > 600 ? 32 : 24;
          final double contentMax = maxW > 900 ? 560 : maxW;
          return ThemedRefreshIndicator(
            onRefresh: dashboard.refreshDashboard,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    0,
                    horizontalPad,
                    72,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMax),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _fade(0, const DashboardGreetingHeader()),
                            const SizedBox(height: 8),
                            _fade(
                              1,
                              EliteHeroCard.dashboard(
                                isLoading: daily.isLoading,
                                totalRecebido: daily.totalRecebido,
                                totalDespesas: daily.totalDespesas,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _fade(
                              2,
                              DashboardStatsRow(
                                cars: daily.totalCarros,
                                inProgress: daily.emAndamento,
                                onInProgressTap:
                                    () => dashboard.openInProgressServices(
                                      status: ServiceStatus.emAndamento,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _fade(
                              3,
                              DashboardQuickActions(
                                onNovoAtendimento:
                                    () =>
                                        Get.toNamed(AppRoutes.novoAtendimento),
                                onRelatorioDiario: dashboard.openDailyReport,
                                onRelatorioPeriodo:
                                    dashboard.openIntervalReport,
                                onDespesas: dashboard.openExpenses,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _fade(4, DashboardRecebimentoSection(daily: daily)),
                            const SizedBox(height: 10),
                            _fade(5, DashboardDespesasSection(daily: daily)),
                            const SizedBox(height: 10),
                            _fade(
                              6,
                              DashboardMonthlyPerformanceSection(
                                reports: dashboard.reportController,
                                onOpenMonthly: dashboard.openMonthlyReport,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _fade(
                              7,
                              DashboardAtendimentosSection(
                                onVerTodos:
                                    () => dashboard.openInProgressServices(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _fade(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_fadeAnimations[index]),
        child: child,
      ),
    );
  }
}
