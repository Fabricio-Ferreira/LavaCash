import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lava_cash/app/theme/app_colors.dart';

/// Large elapsed timer, status pill, and entry / duration cards.
class ServiceTimerSection extends StatelessWidget {
  const ServiceTimerSection({
    super.key,
    required this.elapsedHoursMinutes,
    required this.durationFull,
    required this.entryTime,
  });

  final String elapsedHoursMinutes;
  final String durationFull;
  final DateTime entryTime;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String entryLabel = DateFormat('HH:mm').format(entryTime.toLocal());
    return Column(
      children: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              elapsedHoursMinutes,
              style: textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.onSurface,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'EM ANDAMENTO',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            Expanded(child: _InfoCard(label: 'ENTRADA', value: entryLabel)),
            const SizedBox(width: 12),
            Expanded(child: _InfoCard(label: 'DURAÇÃO', value: durationFull)),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
