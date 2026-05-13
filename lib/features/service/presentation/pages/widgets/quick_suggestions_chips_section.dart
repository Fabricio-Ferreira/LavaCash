import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';
import 'package:lava_cash/core/utils/formatters.dart';
import 'package:lava_cash/features/service/presentation/controllers/service_controller.dart';

/// Quick-suggestion chips driven by [ServiceController.quickSuggestions].
class QuickSuggestionsChipsSection extends GetView<ServiceController> {
  const QuickSuggestionsChipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Obx(() {
      final List<ServiceCatalogItem> items =
          controller.quickSuggestions.toList();
      if (items.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
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
                  items.map((ServiceCatalogItem e) {
                    return ActionChip(
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
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.45),
                      ),
                      backgroundColor: Colors.white,
                      pressElevation: 2,
                      onPressed: () => controller.addLineFromCatalogItem(e),
                    );
                  }).toList(),
            ),
          ],
        ),
      );
    });
  }
}
