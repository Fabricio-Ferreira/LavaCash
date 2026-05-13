import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';
import 'package:lava_cash/core/utils/home_tab_scroll_padding.dart';
import 'package:lava_cash/core/utils/keyboard_utils.dart';
import 'package:lava_cash/core/widgets/gradient_bottom_cta.dart';
import 'package:lava_cash/features/service_catalog/presentation/controllers/service_catalog_controller.dart';
import 'package:lava_cash/features/service_catalog/presentation/widgets/services_catalog_item_card.dart';

/// Home tab: CRUD service catalog (bottom nav "Serviços").
class ServicesCatalogTab extends StatefulWidget {
  const ServicesCatalogTab({super.key});

  @override
  State<ServicesCatalogTab> createState() => _ServicesCatalogTabState();
}

class _ServicesCatalogTabState extends State<ServicesCatalogTab> {
  final TextEditingController _searchController = TextEditingController();

  ServiceCatalogController get _controller =>
      Get.find<ServiceCatalogController>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _executeClearSearchQuery() {
    _searchController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double bottomPad = homeTabListBottomPadding(context);
    final EdgeInsets catalogCtaPadding = EdgeInsets.fromLTRB(
      24,
      12,
      24,
      homeTabFabBottomPadding(context),
    );
    return GestureDetector(
      onTap: AppKeyboardUtils.hideKeyboard,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Catálogo de serviços',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou observação',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: AppColors.outline.withValues(alpha: 0.6),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.outline,
                  ),
                  suffixIcon:
                      _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpar busca',
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.outline,
                              ),
                              onPressed: _executeClearSearchQuery,
                            ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            Obx(() {
              final String errBanner = _controller.errorMessage.value;
              final bool showErrBanner =
                  errBanner.isNotEmpty && _controller.items.isNotEmpty;
              if (!showErrBanner) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: SelectableText.rich(
                  TextSpan(
                    text: errBanner,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value && _controller.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final String err = _controller.errorMessage.value;
                if (err.isNotEmpty && _controller.items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SelectableText.rich(
                        TextSpan(
                          text: err,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  );
                }
                final String searchQueryRaw = _searchController.text;
                final bool catalogEmpty = _controller.items.isEmpty;
                final List<ServiceCatalogItem> displayed = _controller
                    .buildDisplayedCatalogLines(searchQueryRaw);
                return RefreshIndicator(
                  onRefresh: _controller.refreshCatalog,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: <Widget>[
                      if (catalogEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                24,
                                0,
                                24,
                                bottomPad + 16,
                              ),
                              child: Text(
                                'Nenhum serviço cadastrado. Use Adicionar '
                                'serviço abaixo.',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      else if (displayed.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                24,
                                0,
                                24,
                                bottomPad + 16,
                              ),
                              child: Text(
                                'Nenhum serviço corresponde à busca.',
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
                          padding: EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            bottomPad + 16,
                          ),
                          sliver: SliverList.separated(
                            itemCount: displayed.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) {
                              final ServiceCatalogItem item = displayed[index];
                              return ServicesCatalogItemCard(item: item);
                            },
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            GradientBottomCta(
              isEnabled: true,
              onPressed: () => _controller.onAddCatalogItem(context),
              icon: Icons.add_circle,
              iconSize: 28,
              label: 'Adicionar serviço',
              contentPadding: catalogCtaPadding,
            ),
          ],
        ),
      ),
    );
  }
}
