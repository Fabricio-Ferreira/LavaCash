import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/themed_refresh_indicator.dart';
import '../../../../shared/widgets/elite_hero_card.dart';
import '../../../../shared/widgets/payment_list_card.dart';
import '../controllers/interval_report_controller.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/dashboard_stat_grid.dart';
import '../widgets/interval_report_range_header.dart';

double _summaryDouble(Map<String, dynamic>? m, String k) {
  if (m == null) {
    return 0;
  }
  final Object? o = m[k];
  if (o == null) {
    return 0;
  }
  if (o is num) {
    return o.toDouble();
  }
  return double.tryParse(o.toString()) ?? 0;
}

int _summaryInt(Map<String, dynamic>? m, String k) {
  if (m == null) {
    return 0;
  }
  final Object? o = m[k];
  if (o == null) {
    return 0;
  }
  if (o is int) {
    return o;
  }
  if (o is num) {
    return o.toInt();
  }
  return int.tryParse(o.toString()) ?? 0;
}

List<MapEntry<String, double>> _paymentEntriesFromSummary(
  Map<String, dynamic>? m,
) {
  if (m == null) {
    return <MapEntry<String, double>>[];
  }
  double d(String key) => _summaryDouble(m, key);
  final List<MapEntry<String, double>> list = <MapEntry<String, double>>[];
  void add(String formaKey, String mapKey) {
    final double v = d(mapKey);
    if (v > 0.009) {
      list.add(MapEntry<String, double>(formaKey, v));
    }
  }
  add('dinheiro', 'total_dinheiro');
  add('pix', 'total_pix');
  add('debito', 'total_debito');
  add('credito', 'total_credito');
  add('link', 'total_link');
  list.sort(
    (MapEntry<String, double> a, MapEntry<String, double> b) =>
        b.value.compareTo(a.value),
  );
  return list;
}

/// Relatório por intervalo (datas inclusivas).
class IntervalReportTab extends GetView<IntervalReportController> {
  const IntervalReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final bool loading = controller.isLoading.value;
      final Map<String, dynamic>? sum = controller.summary.value;
      final String err = controller.errorMessage.value;
      final double totalEntradas = _summaryDouble(sum, 'total_entradas');
      final double totalSaidas = _summaryDouble(sum, 'total_saidas');
      final double saldo = _summaryDouble(sum, 'saldo_liquido');
      final int lavagens = _summaryInt(sum, 'total_lavagens');
      final double ticketMedio =
          lavagens > 0 ? totalEntradas / lavagens : 0;
      final List<MapEntry<String, double>> paymentEntries =
          _paymentEntriesFromSummary(sum);
      return ThemedRefreshIndicator(
        onRefresh: () async {
          await controller.load();
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final double pad = c.maxWidth > 600 ? 24 : 16;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(pad, 8, pad, 120),
              children: <Widget>[
                const IntervalReportRangeHeader(),
                if (err.isNotEmpty && !loading && sum == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SelectableText.rich(
                      TextSpan(
                        text: err,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                EliteHeroCard.intervalReport(
                  isLoading: loading,
                  totalRecebido: totalEntradas,
                ),
                const SizedBox(height: 16),
                DashboardStatGrid(
                  children: <Widget>[
                    DashboardStatCard(
                      icon: Icons.directions_car_outlined,
                      iconColor: AppColors.primary,
                      label: 'LAVAGENS',
                      value: loading ? '—' : '$lavagens',
                    ),
                    DashboardStatCard(
                      icon: Icons.payments_outlined,
                      iconColor: AppColors.primary,
                      label: 'TICKET MÉDIO',
                      value:
                          loading
                              ? '—'
                              : AppFormatters.formatCurrency(ticketMedio),
                    ),
                    DashboardStatCard(
                      icon: Icons.trending_down_outlined,
                      iconColor: AppColors.tertiary,
                      label: 'DESPESAS',
                      value:
                          loading
                              ? '—'
                              : AppFormatters.formatCurrency(totalSaidas),
                    ),
                    DashboardStatCard(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: AppColors.primary,
                      label: 'SALDO',
                      value:
                          loading
                              ? '—'
                              : AppFormatters.formatCurrency(saldo),
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
                  entries: paymentEntries,
                  isLoading: loading,
                  emptyMessage: 'Nenhum recebimento no período',
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
