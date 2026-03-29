import 'package:flutter/material.dart';

import 'monthly_report_tab.dart';

/// Shell with [AppBar] for full-screen monthly report (from dashboard shortcut).
class MonthlyReportRoutePage extends StatelessWidget {
  const MonthlyReportRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatório mensal')),
      body: const MonthlyReportTab(),
    );
  }
}
