import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';
import 'package:lava_cash/core/domain/service_catalog/repositories/service_catalog_repository.dart';
import 'package:lava_cash/core/error/failures.dart';
import 'package:lava_cash/core/utils/app_snackbar.dart';
import 'package:lava_cash/core/utils/formatters.dart';
import 'package:lava_cash/features/service/presentation/pages/widgets/service_detail_form.dart';

/// Bottom sheet to create a catalog item using [ServiceDetailFormFields] layout.
Future<ServiceCatalogItem?> showServiceCatalogNewItemSheet({
  required BuildContext context,
}) async {
  return showModalBottomSheet<ServiceCatalogItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) => const _ServiceCatalogNewItemSheetBody(),
  );
}

class _ServiceCatalogNewItemSheetBody extends StatefulWidget {
  const _ServiceCatalogNewItemSheetBody();

  @override
  State<_ServiceCatalogNewItemSheetBody> createState() =>
      _ServiceCatalogNewItemSheetBodyState();
}

class _ServiceCatalogNewItemSheetBodyState
    extends State<_ServiceCatalogNewItemSheetBody> {
  late final TextEditingController _nomeController;
  late final TextEditingController _valorController;
  late final TextEditingController _obsController;
  bool _saving = false;
  bool _maisUtilizado = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _valorController = TextEditingController();
    _obsController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      AppSnackbar.showError('Informe o nome do serviço.');
      return;
    }
    final double? valor = AppFormatters.parseMoneyInput(_valorController.text);
    if (valor == null || valor <= 0) {
      AppSnackbar.showError('Informe um valor válido.');
      return;
    }
    final ServiceCatalogRepository repo = Get.find<ServiceCatalogRepository>();
    setState(() {
      _saving = true;
    });
    final Either<Failure, ServiceCatalogItem> result = await repo.createItem(
      nome: nome,
      valorPadrao: valor,
      observacao:
          _obsController.text.trim().isEmpty
              ? null
              : _obsController.text.trim(),
      isMaisUtilizado: _maisUtilizado,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
    });
    result.fold((Failure failure) => AppSnackbar.showError(failure.message), (
      ServiceCatalogItem item,
    ) {
      Navigator.of(context).pop(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Novo serviço',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ServiceDetailFormFields(
                    nomeController: _nomeController,
                    valorController: _valorController,
                    observacaoController: _obsController,
                    isLoading: _saving,
                    onPrimaryPressed: _save,
                    nomeHintText: 'Digite o nome do serviço',
                    valorFieldLabel: 'Valor padrão',
                    obsFieldLabel: 'Observações (opcional)',
                    obsHintText: 'Observações (opcional)',
                    primaryButtonLabel: 'Salvar no catálogo',
                    showPrimaryIcon: false,
                    beforePrimaryButton: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Sugestões rápidas (até 3)'),
                      subtitle: const Text('Aparece como chip no atendimento.'),
                      value: _maisUtilizado,
                      activeTrackColor: AppColors.primary.withValues(
                        alpha: 0.45,
                      ),
                      activeThumbColor: AppColors.primary,
                      onChanged:
                          _saving
                              ? null
                              : (bool value) =>
                                  setState(() => _maisUtilizado = value),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
