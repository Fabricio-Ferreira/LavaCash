import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lava_cash/core/error/failures.dart';
import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';
import 'package:lava_cash/core/domain/service_catalog/repositories/service_catalog_repository.dart';
import 'package:lava_cash/core/utils/catalog_search_normalize.dart';
import 'package:lava_cash/core/utils/app_snackbar.dart';
import 'package:lava_cash/core/widgets/app_confirmation_dialog.dart';
import 'package:lava_cash/features/service_catalog/presentation/widgets/service_catalog_editor_sheet.dart';

class ServiceCatalogController extends GetxController {
  ServiceCatalogController({required ServiceCatalogRepository repository})
    : _repository = repository;

  final ServiceCatalogRepository _repository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ServiceCatalogItem> items = <ServiceCatalogItem>[].obs;

  @override
  void onReady() {
    super.onReady();
    refreshCatalog();
  }

  Future<void> refreshCatalog() async {
    isLoading.value = true;
    final Either<Failure, List<ServiceCatalogItem>> result =
        await _repository.listActiveCatalog();
    result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        items.clear();
      },
      (List<ServiceCatalogItem> list) {
        errorMessage.value = '';
        items.assignAll(list);
      },
    );
    isLoading.value = false;
  }

  Future<Either<Failure, ServiceCatalogItem>> createItem({
    required String nome,
    required double valorPadrao,
    String? observacao,
    required bool isMaisUtilizado,
  }) {
    return _repository.createItem(
      nome: nome,
      valorPadrao: valorPadrao,
      observacao: observacao,
      isMaisUtilizado: isMaisUtilizado,
    );
  }

  Future<Either<Failure, ServiceCatalogItem>> updateItem({
    required String id,
    required String nome,
    required double valorPadrao,
    String? observacao,
    required bool isMaisUtilizado,
  }) {
    return _repository.updateItem(
      id: id,
      nome: nome,
      valorPadrao: valorPadrao,
      observacao: observacao,
      isMaisUtilizado: isMaisUtilizado,
    );
  }

  Future<Either<Failure, Unit>> softDelete(String id) {
    return _repository.softDeleteItem(id);
  }

  void onAddCatalogItem(BuildContext context) {
    showServiceCatalogEditorSheet(context: context);
  }

  void onEditCatalogItem(BuildContext context, ServiceCatalogItem item) {
    showServiceCatalogEditorSheet(context: context, existing: item);
  }

  /// Sort hint: mais utilizados first, then by name (ASCII case-fold).
  void executeSortCatalogByQuickSuggestion(List<ServiceCatalogItem> list) {
    list.sort((ServiceCatalogItem a, ServiceCatalogItem b) {
      if (a.isMaisUtilizado != b.isMaisUtilizado) {
        return (b.isMaisUtilizado ? 1 : 0) - (a.isMaisUtilizado ? 1 : 0);
      }
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });
  }

  /// Accent- and case-insensitive substring on [nome] or [observacao].
  List<ServiceCatalogItem> filterCatalogEntriesBySearchQuery(
    List<ServiceCatalogItem> sortedCatalog,
    String rawQuery,
  ) {
    final String query = rawQuery.trim();
    if (query.isEmpty) {
      return sortedCatalog;
    }
    final String foldedQuery = normalizeCatalogSearchText(query);
    return sortedCatalog.where((ServiceCatalogItem item) {
      if (normalizeCatalogSearchText(item.nome).contains(foldedQuery)) {
        return true;
      }
      final String observacaoText = item.observacao ?? '';
      if (observacaoText.isEmpty) {
        return false;
      }
      return normalizeCatalogSearchText(observacaoText).contains(foldedQuery);
    }).toList();
  }

  /// Snapshot of [items]: sorted catalog rules, then search filter.
  List<ServiceCatalogItem> buildDisplayedCatalogLines(String rawSearchQuery) {
    final List<ServiceCatalogItem> sorted = items.toList();
    executeSortCatalogByQuickSuggestion(sorted);
    return filterCatalogEntriesBySearchQuery(sorted, rawSearchQuery);
  }

  Future<void> onDeleteCatalogItem(
    BuildContext context,
    ServiceCatalogItem item,
  ) async {
    final bool? ok = await AppDialog.show(
      title: 'Excluir serviço',
      message:
          'Remover "${item.nome}" do catálogo? '
          'Ele deixa de aparecer nas sugestões.',
      confirmLabel: 'Excluir',
      confirmIsDestructive: true,
    );
    if (ok != true) {
      return;
    }
    final Either<Failure, Unit> r = await softDelete(item.id);
    r.fold((Failure f) => AppSnackbar.showError(f.message), (_) {
      AppSnackbar.showSuccess('Serviço removido.');
      refreshCatalog();
    });
  }
}
