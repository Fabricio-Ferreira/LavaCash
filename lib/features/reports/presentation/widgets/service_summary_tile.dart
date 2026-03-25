import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/service_status.dart';
import '../../../../domain/entities/service_summary.dart';

class ServiceSummaryTile extends StatelessWidget {
  const ServiceSummaryTile({super.key, required this.summary});

  final ServiceSummary summary;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String timeLabel = DateFormat('HH:mm').format(summary.horaEntrada);
    final String plateLabel = AppFormatters.formatPlate(summary.placa);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ClientAvatar(name: summary.clienteNome),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.clienteNome,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '$plateLabel • $timeLabel',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                summary.valor != null
                    ? AppFormatters.formatCurrency(summary.valor!)
                    : '—',
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              _StatusBadge(status: summary.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientAvatar extends StatelessWidget {
  const _ClientAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final String initials = _initialsFromName(name);
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.surfaceContainerHigh,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

String _initialsFromName(String name) {
  final List<String> parts =
      name
          .trim()
          .split(RegExp(r'\s+'))
          .where((String p) => p.isNotEmpty)
          .toList();
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    final String first = parts.first;
    return first.isNotEmpty ? first[0].toUpperCase() : '?';
  }
  final String a = parts[0];
  final String b = parts[1];
  final String ca = a.isNotEmpty ? a[0] : '';
  final String cb = b.isNotEmpty ? b[0] : '';
  return ('$ca$cb').toUpperCase();
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ServiceStatus status;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final _BadgeStyle style = _badgeStyleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.foreground),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: textTheme.labelSmall?.copyWith(
              color: style.foreground,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;
}

_BadgeStyle _badgeStyleFor(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.finalizado:
      return const _BadgeStyle(
        label: 'COMPLETO',
        background: Color(0xFFE8F5E9),
        foreground: AppColors.primary,
        icon: Icons.check_circle_outline,
      );
    case ServiceStatus.emAndamento:
      return const _BadgeStyle(
        label: 'EM CURSO',
        background: Color(0xFFE3F2FD),
        foreground: Color(0xFF1565C0),
        icon: Icons.schedule,
      );
    case ServiceStatus.cancelado:
      return const _BadgeStyle(
        label: 'CANCELADO',
        background: Color(0xFFFFEBEE),
        foreground: Color(0xFFC62828),
        icon: Icons.cancel_outlined,
      );
  }
}
