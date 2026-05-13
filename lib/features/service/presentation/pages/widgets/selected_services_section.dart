import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lava_cash/core/domain/entities/attendance_service_line.dart';
import 'package:lava_cash/features/service/presentation/controllers/service_controller.dart';
import 'package:lava_cash/features/service/presentation/pages/widgets/attendance_service_line_card.dart';

/// Header + list of lines for the current attendance (reactive).
class SelectedServicesSection extends GetView<ServiceController> {
  const SelectedServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final List<AttendanceServiceLine> lines =
          controller.attendanceLines.toList();
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
              key: ValueKey<String>(line.id),
              padding: EdgeInsets.only(bottom: i < lines.length - 1 ? 12 : 0),
              child: AttendanceServiceLineCard(line: line),
            );
          }),
        ],
      );
    });
  }
}
