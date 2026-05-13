import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';
import 'package:lava_cash/core/domain/service_catalog/repositories/service_catalog_repository.dart';
import 'package:lava_cash/core/error/failures.dart';
import 'package:lava_cash/core/utils/app_snackbar.dart';
import 'package:lava_cash/core/utils/formatters.dart';
import 'package:lava_cash/features/service/presentation/controllers/service_controller.dart';
import 'package:lava_cash/features/service/presentation/pages/widgets/service_catalog_new_item_sheet.dart';

/// Full-screen multi-select picker for catalog services (no home bottom bar).
class ServiceCatalogSelectPage extends StatefulWidget {
  const ServiceCatalogSelectPage({super.key});

  @override
  State<ServiceCatalogSelectPage> createState() =>
      _ServiceCatalogSelectPageState();
}

class _ServiceCatalogSelectPageState extends State<ServiceCatalogSelectPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{};
  final List<ServiceCatalogItem> _allItems = <ServiceCatalogItem>[];
  bool _loading = true;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    final ServiceCatalogRepository repo = Get.find<ServiceCatalogRepository>();
    final Either<Failure, List<ServiceCatalogItem>> result =
        await repo.listActiveCatalog();
    if (!mounted) {
      return;
    }
    result.fold(
      (Failure failure) {
        AppSnackbar.showError(failure.message);
        setState(() {
          _allItems.clear();
          _loading = false;
        });
      },
      (List<ServiceCatalogItem> list) {
        _sortCatalog(list);
        setState(() {
          _allItems.clear();
          _allItems.addAll(list);
          _loading = false;
        });
      },
    );
  }

  void _sortCatalog(List<ServiceCatalogItem> list) {
    list.sort((ServiceCatalogItem a, ServiceCatalogItem b) {
      if (a.isMaisUtilizado != b.isMaisUtilizado) {
        return (b.isMaisUtilizado ? 1 : 0) - (a.isMaisUtilizado ? 1 : 0);
      }
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });
  }

  List<ServiceCatalogItem> _visibleOrdered() {
    if (_searchText.trim().isEmpty) {
      return List<ServiceCatalogItem>.from(_allItems);
    }
    final String q = _searchText.trim().toLowerCase();
    return _allItems.where((ServiceCatalogItem e) {
      if (e.nome.toLowerCase().contains(q)) {
        return true;
      }
      final String? o = e.observacao;
      return o != null && o.toLowerCase().contains(q);
    }).toList();
  }

  List<ServiceCatalogItem> _selectedInCatalogOrder() {
    return _allItems
        .where((ServiceCatalogItem e) => _selectedIds.contains(e.id))
        .toList();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _onContinue() async {
    final List<ServiceCatalogItem> picked = _selectedInCatalogOrder();
    if (picked.isEmpty) {
      return;
    }
    final ServiceController controller = Get.find<ServiceController>();
    if (controller.isAddingDetails.value) {
      return;
    }
    await controller.addSelectedCatalogItemsToAttendance(picked);
    await controller.loadQuickSuggestions();
    Get.close(1);
  }

  Future<void> _openCreateSheet() async {
    final ServiceCatalogItem? created = await showServiceCatalogNewItemSheet(
      context: context,
    );
    if (!mounted || created == null) {
      return;
    }
    setState(() {
      _allItems.add(created);
      _sortCatalog(_allItems);
      _selectedIds.add(created.id);
    });
    AppSnackbar.showSuccess('Serviço criado e selecionado.');
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<ServiceCatalogItem> visible = _visibleOrdered();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Selecionar Serviço')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Escolha o melhor cuidado',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preços transparentes para sua frota.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar serviço',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon:
                    _searchText.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                filled: true,
                fillColor: AppColors.surfaceContainerHigh.withValues(
                  alpha: 0.55,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 14,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: _openCreateSheet,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Criar novo serviço'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : visible.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              _allItems.isEmpty
                                  ? 'Nenhum serviço cadastrado ainda.'
                                  : 'Nenhum resultado para a busca.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge,
                            ),
                            if (_allItems.isEmpty) ...<Widget>[
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _openCreateSheet,
                                child: const Text('Criar primeiro serviço'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      itemCount: visible.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ServiceCatalogItem item = visible[index];
                        final bool isSelected = _selectedIds.contains(item.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CatalogSelectTile(
                            item: item,
                            isSelected: isSelected,
                            onTap: () => _toggleSelection(item.id),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Obx(() {
            final ServiceController attendance = Get.find<ServiceController>();
            final bool posting = attendance.isAddingDetails.value;
            return FilledButton(
              onPressed:
                  _selectedIds.isEmpty || _loading || posting
                      ? null
                      : _onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Continuar',
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _CatalogSelectTile extends StatelessWidget {
  const _CatalogSelectTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final ServiceCatalogItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant.withValues(alpha: 0.35),
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_car_wash_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.nome,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (item.observacao != null &&
                            item.observacao!.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            item.observacao!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppFormatters.formatCurrency(item.valorPadrao),
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
