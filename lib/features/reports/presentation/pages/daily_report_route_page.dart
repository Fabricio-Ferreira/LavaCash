import 'package:flutter/material.dart';

import 'daily_report_tab.dart';

/// Shell with [AppBar] for full-screen daily report (from dashboard shortcut).
class DailyReportRoutePage extends StatelessWidget {
  const DailyReportRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatório diário')),
      body: const DailyReportTab(),
    );
  }
}
