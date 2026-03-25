import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import '../controllers/report_controller.dart';
import '../models/daily_report_state.dart';
import '../widgets/dashboard_greeting_header.dart';
import '../widgets/dashboard_hero_total_card.dart';
import '../widgets/dashboard_atendimentos_section.dart';
import '../widgets/dashboard_monthly_performance_section.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_recebimento_section.dart';
import '../widgets/dashboard_stats_row.dart';
import 'daily_report_tab.dart';
import 'monthly_report_tab.dart';
import 'today_services_page.dart';

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
    _fadeAnimations = List<Animation<double>>.generate(
      7,
      (int i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            i * 0.08,
            0.55 + i * 0.07,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ReportController reports = Get.find<ReportController>();
      reports.loadDaily();
      reports.loadMonthly();
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
    final ReportController reports = Get.find<ReportController>();
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final DailyReportState daily = DailyReportState.fromController(reports);
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxW = constraints.maxWidth;
          final double horizontalPad = maxW > 600 ? 32 : 24;
          final double contentMax = maxW > 900 ? 560 : maxW;
          return ThemedRefreshIndicator(
            onRefresh: () async {
              await reports.loadDaily();
              await reports.loadMonthly();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    8,
                    horizontalPad,
                    120,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMax),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _fade(
                              0,
                              DashboardGreetingHeader(textTheme: textTheme),
                            ),
                            const SizedBox(height: 24),
                            _fade(1, DashboardHeroTotalCard(daily: daily)),
                            const SizedBox(height: 16),
                            _fade(
                              2,
                              DashboardStatsRow(
                                cars: daily.totalCarros,
                                inProgress: daily.emAndamento,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _fade(
                              3,
                              DashboardQuickActions(
                                onNovoAtendimento:
                                    () => Get.toNamed(AppRoutes.registration),
                                onRelatorioDiario:
                                    () => _openDailyReport(context),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _fade(
                              4,
                              DashboardRecebimentoSection(
                                daily: daily,
                                textTheme: textTheme,
                              ),
                            ),
                            const SizedBox(height: 28),
                            _fade(
                              6,
                              DashboardMonthlyPerformanceSection(
                                reports: reports,
                                textTheme: textTheme,
                                onOpenMonthly: () => _openMonthlyReport(),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _fade(
                              5,
                              DashboardAtendimentosSection(
                                textTheme: textTheme,
                                onVerTodos: _openTodayServices,
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

  void _openDailyReport(BuildContext context) {
    final ReportController r = Get.find<ReportController>();
    r.loadDaily();
    Get.to<void>(
      () => Scaffold(
        appBar: AppBar(title: const Text('Relatório diário')),
        body: const DailyReportTab(),
      ),
    );
  }

  void _openMonthlyReport() {
    final ReportController r = Get.find<ReportController>();
    r.loadMonthly();
    Get.to<void>(
      () => Scaffold(
        appBar: AppBar(title: const Text('Relatório mensal')),
        body: const MonthlyReportTab(),
      ),
    );
  }

  void _openTodayServices() {
    final ReportController r = Get.find<ReportController>();
    r.loadTodayServices();
    Get.to<void>(
      () => Scaffold(
        appBar: AppBar(title: const Text('Atendimentos do dia')),
        body: const TodayServicesPage(),
      ),
    );
  }
}
