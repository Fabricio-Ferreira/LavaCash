import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/interval_report_controller.dart';
import '../controllers/report_controller.dart';
import '../daily/daily_report_tab.dart';
import '../monthly/monthly_report_tab.dart';
import '../period/interval_report_tab.dart';

/// Relatórios with Diário / Mensal sub-tabs (Stitch-style shell).
class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            elevation: 0,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                padding: const EdgeInsets.all(6),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Diário'),
                  Tab(text: 'Mensal'),
                  Tab(text: 'Período'),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                tooltip: 'Exportar PDF',
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 22),
                color: AppColors.primary,
                onPressed: () {
                  final ReportController c = Get.find<ReportController>();
                  if (_tabController.index == 0) {
                    c.exportDailyPdf();
                  } else if (_tabController.index == 1) {
                    c.exportMonthlyPdf();
                  } else {
                    Get.find<IntervalReportController>().exportPdf();
                  }
                },
              ),
              IconButton(
                tooltip: 'Imprimir',
                icon: const Icon(Icons.print_outlined, size: 22),
                color: AppColors.primary,
                onPressed: () {
                  final ReportController c = Get.find<ReportController>();
                  if (_tabController.index == 0) {
                    c.printDailyPdf();
                  } else if (_tabController.index == 1) {
                    c.printMonthlyPdf();
                  } else {
                    Get.find<IntervalReportController>().printPdf();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: const [
              DailyReportTab(),
              MonthlyReportTab(),
              IntervalReportTab(),
            ],
          ),
        ),
      ],
    );
  }
}
