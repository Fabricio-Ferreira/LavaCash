import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';

class DashboardGreetingHeader extends StatelessWidget {
  const DashboardGreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String rawDateLine =
        DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now);
    final String dateLine =
        toBeginningOfSentenceCase(rawDateLine) ?? rawDateLine;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
}
