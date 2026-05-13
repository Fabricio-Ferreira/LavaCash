import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/domain/entities/attendance_service_line.dart';
import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';
import 'package:lava_cash/core/utils/formatters.dart';

class SelectedServicesSection extends StatelessWidget {
  const SelectedServicesSection({
    super.key,
    required this.lines,
    required this.onRemove,
  });

  final List<AttendanceServiceLine> lines;
  final ValueChanged<AttendanceServiceLine> onRemove;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Serviços selecionados',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...List<Widget>.generate(lines.length, (int i) {
          final AttendanceServiceLine line = lines[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < lines.length - 1 ? 12 : 0),
            child: _ServiceLineCard(
              line: line,
              onRemove: () => onRemove(line),
            ),
          );
        }),
      ],
    );
  }
}

class _ServiceLineCard extends StatelessWidget {
  const _ServiceLineCard({required this.line, required this.onRemove});

  final AttendanceServiceLine line;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_car_wash_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    line.nome,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (line.observacao != null &&
                      line.observacao!.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      line.observacao!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  AppFormatters.formatCurrency(line.valor),
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.onSurfaceVariant,
                  onPressed: onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuickSuggestionsChips extends StatelessWidget {
  const QuickSuggestionsChips({
    super.key,
    required this.items,
    required this.onTap,
  });

  final List<ServiceCatalogItem> items;
  final ValueChanged<ServiceCatalogItem> onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'SUGESTÕES RÁPIDAS',
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              items
                  .map(
                    (ServiceCatalogItem e) => ActionChip(
                      avatar: Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        '${e.nome} — ${AppFormatters.formatCurrency(e.valorPadrao)}',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      side: BorderSide(color: AppColors.primary.withValues(
                        alpha: 0.45,
                      )),
                      backgroundColor: Colors.white,
                      onPressed: () => onTap(e),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class DashedAddServiceButton extends StatelessWidget {
  const DashedAddServiceButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return CustomPaint(
      painter: _DashedRoundedRectPainter(
        color: AppColors.outlineVariant.withValues(alpha: 0.8),
        radius: 16,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add_circle_outline, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'Adicionar serviço',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  _DashedRoundedRectPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;
    _drawDashedRRect(canvas, rrect, paint);
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    final Path path = Path()..addRRect(rrect);
    for (final PathMetric metric in path.computeMetrics()) {
      double dist = 0;
      const double dash = 6;
      const double gap = 4;
      while (dist < metric.length) {
        final double next = (dist + dash).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
