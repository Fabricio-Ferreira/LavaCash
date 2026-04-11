import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'package:lava_cash/core/domain/entities/service_summary.dart';
import '../../../../shared/widgets/service_summary_tile.dart';

/// Preview list + loading / error / empty states for dashboard atendimentos.
class DashboardAtendimentosPreviewBody extends StatelessWidget {
  const DashboardAtendimentosPreviewBody({
    super.key,
    required this.textTheme,
    required this.isLoading,
    required this.preview,
    required this.errorMessage,
  });

  final TextTheme textTheme;
  final bool isLoading;
  final List<ServiceSummary> preview;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty && preview.isEmpty && !isLoading) {
      return SelectableText.rich(
        TextSpan(
          text: errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (isLoading && preview.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (preview.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Nenhum atendimento hoje.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }
    return Column(
      children: List<Widget>.generate(preview.length, (int index) {
        final Widget tile = ServiceSummaryTile(summary: preview[index]);
        if (index == preview.length - 1) {
          return tile;
        }
        return Column(
          children: <Widget>[
            tile,
            Divider(
              height: 1,
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ],
        );
      }),
    );
  }
}
