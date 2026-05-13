import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';
import 'package:lava_cash/core/utils/home_tab_scroll_padding.dart';
import 'package:lava_cash/features/service_catalog/presentation/controllers/service_catalog_controller.dart';
import 'package:lava_cash/features/service_catalog/presentation/widgets/services_catalog_item_card.dart';

void _sortCatalogByQuickSuggestion(List<ServiceCatalogItem> list) {
  list.sort((ServiceCatalogItem a, ServiceCatalogItem b) {
    if (a.isMaisUtilizado != b.isMaisUtilizado) {
      return (b.isMaisUtilizado ? 1 : 0) - (a.isMaisUtilizado ? 1 : 0);
    }
    return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
  });
}

/// Home tab: CRUD service catalog (bottom nav "Serviços").
class ServicesCatalogTab extends GetView<ServiceCatalogController> {
  const ServicesCatalogTab({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double bottomPad = homeTabListBottomPadding(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final String err = controller.errorMessage.value;
        if (err.isNotEmpty && controller.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SelectableText.rich(
                TextSpan(text: err, style: const TextStyle(color: Colors.red)),
              ),
            ),
          );
        }
        final List<ServiceCatalogItem> list = controller.items.toList();
        _sortCatalogByQuickSuggestion(list);
        return RefreshIndicator(
          onRefresh: controller.refreshCatalog,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Catálogo de serviços',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (err.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SelectableText.rich(
                        TextSpan(
                          text: err,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
              if (list.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad + 80),
                      child: Text(
                        'Nenhum serviço cadastrado. Toque em + para criar.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 88),
                  sliver: SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final ServiceCatalogItem item = list[index];
                      return ServicesCatalogItemCard(
                        item: item,
                        controller: controller,
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      }),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: homeTabFabBottomPadding(context)),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => controller.onAddCatalogItem(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
