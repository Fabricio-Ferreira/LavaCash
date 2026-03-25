import '../../../../domain/entities/monthly_report.dart';

double? computeGrowthPercentVsPreviousMonth(
  List<MonthlyReport> list,
  MonthlyReport? highlight,
) {
  if (highlight == null || list.length < 2) {
    return null;
  }
  final List<MonthlyReport> sorted = List<MonthlyReport>.from(list)
    ..sort((MonthlyReport a, MonthlyReport b) => a.mes.compareTo(b.mes));
  final int idx = sorted.indexWhere(
    (MonthlyReport m) =>
        m.mes.year == highlight.mes.year && m.mes.month == highlight.mes.month,
  );
  if (idx <= 0) {
    return null;
  }
  final MonthlyReport prev = sorted[idx - 1];
  if (prev.faturamento == 0) {
    return null;
  }
  return ((highlight.faturamento - prev.faturamento) / prev.faturamento) * 100;
}
