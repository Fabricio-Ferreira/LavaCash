import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';

class DashboardGreetingHeader extends StatelessWidget {
  const DashboardGreetingHeader({super.key, required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String greeting = greetingForHour(now.hour);
    final String dateLine =
        toBeginningOfSentenceCase(
          DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now),
        ) ??
        DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateLine,
          style: textTheme.headlineSmall?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  static String greetingForHour(int hour) {
    if (hour < 12) {
      return 'Bom dia';
    }
    if (hour < 18) {
      return 'Boa tarde';
    }
    return 'Boa noite';
  }
}
