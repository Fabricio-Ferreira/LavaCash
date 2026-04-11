import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';

/// Single control: shows current range and opens [showDateRangePicker].
class IntervalReportDateRangeField extends StatelessWidget {
  const IntervalReportDateRangeField({
    super.key,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onRangeConfirmed,
  });

  final DateTime rangeStart;
  final DateTime rangeEnd;
  final void Function(DateTime startInclusive, DateTime endInclusive)
  onRangeConfirmed;

  Future<void> _openPicker(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime todayD = DateTime(today.year, today.month, today.day);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: rangeStart,
        end: rangeEnd,
      ),
      firstDate: DateTime(2020),
      lastDate: todayD,
      locale: const Locale('pt', 'BR'),
      helpText: 'Período do relatório',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
    );
    if (picked == null) {
      return;
    }
    final DateTime s = DateTime(
      picked.start.year,
      picked.start.month,
      picked.start.day,
    );
    final DateTime e = DateTime(
      picked.end.year,
      picked.end.month,
      picked.end.day,
    );
    onRangeConfirmed(s, e);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateFormat fmt = DateFormat('dd/MM/yyyy', 'pt_BR');
    final String label = '${fmt.format(rangeStart)} — ${fmt.format(rangeEnd)}';
    return Material(
      color: AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _openPicker(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.date_range_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Toque para escolher as datas',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_calendar_outlined,
                color: AppColors.outline,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
