import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/domain/entities/service_catalog_item.dart';
import 'package:lava_cash/core/error/failures.dart';
import 'package:lava_cash/core/utils/app_snackbar.dart';
import 'package:lava_cash/core/utils/formatters.dart';
import 'package:lava_cash/core/utils/brazilian_real_input_formatter.dart';

/// Persists a catalog service (create or update); [existing] id is closed in the callback.
typedef ServiceCatalogPersistFn =
    Future<Either<Failure, ServiceCatalogItem>> Function({
      required String nome,
      required double valorPadrao,
      String? observacao,
      required bool isMaisUtilizado,
    });

/// Shared field group: name, value, notes, primary action.
class ServiceDetailFormFields extends StatelessWidget {
  const ServiceDetailFormFields({
    super.key,
    required this.nomeController,
    required this.valorController,
    required this.observacaoController,
    required this.isLoading,
    required this.onPrimaryPressed,
    this.nomeFieldLabel = 'Nome do serviço',
    this.nomeHintText = 'Ex: Lavagem de carro',
    this.valorFieldLabel = 'Valor do Serviço',
    this.obsFieldLabel = 'Observações (Opcional)',
    this.obsHintText = 'Detalhes adicionais sobre o procedimento...',
    this.primaryButtonLabel = 'Adicionar ao atendimento',
    this.showPrimaryIcon = true,
    this.beforePrimaryButton,
    this.obsMinLines = 1,
    this.obsMaxLines = 3,
  });

  final TextEditingController nomeController;
  final TextEditingController valorController;
  final TextEditingController observacaoController;
  final bool isLoading;
  final VoidCallback onPrimaryPressed;
  final String nomeFieldLabel;
  final String nomeHintText;
  final String valorFieldLabel;
  final String obsFieldLabel;
  final String obsHintText;
  final String primaryButtonLabel;
  final bool showPrimaryIcon;

  /// Inserted after the observations field, before the primary button.
  final Widget? beforePrimaryButton;
  final int obsMinLines;
  final int obsMaxLines;

  static const InputBorder fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color fillColor = AppColors.surfaceContainerHigh.withValues(
      alpha: 0.55,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          nomeFieldLabel,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: nomeController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: nomeHintText,
            hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.outline),
            filled: true,
            fillColor: fillColor,
            border: fieldBorder,
            enabledBorder: fieldBorder,
            focusedBorder: fieldBorder,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          valorFieldLabel,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: valorController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          inputFormatters: const <TextInputFormatter>[
            BrazilianRealInputFormatter(),
          ],
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '0,00',
            hintStyle: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.outline.withValues(alpha: 0.6),
            ),
            prefixText: 'R\$ ',
            prefixStyle: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
            filled: true,
            fillColor: fillColor,
            border: fieldBorder,
            enabledBorder: fieldBorder,
            focusedBorder: fieldBorder,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          obsFieldLabel,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: observacaoController,
          minLines: obsMinLines,
          maxLines: obsMaxLines,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: obsHintText,
            hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.outline),
            alignLabelWithHint: true,
            filled: true,
            fillColor: fillColor,
            border: fieldBorder,
            enabledBorder: fieldBorder,
            focusedBorder: fieldBorder,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        if (beforePrimaryButton != null) ...<Widget>[
          const SizedBox(height: 8),
          beforePrimaryButton!,
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: isLoading ? null : onPrimaryPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 4,
            shadowColor: AppColors.primary.withValues(alpha: 0.45),
          ),
          child:
              isLoading
                  ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (showPrimaryIcon) ...<Widget>[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        primaryButtonLabel,
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }
}

/// Full-width catalog create/edit form (sheet) using [ServiceDetailFormFields].
class ServiceCatalogEditorFormBody extends StatefulWidget {
  const ServiceCatalogEditorFormBody({
    super.key,
    this.existing,
    required this.onPersist,
    this.afterPersistSuccess,
  });

  final ServiceCatalogItem? existing;
  final ServiceCatalogPersistFn onPersist;
  final Future<void> Function()? afterPersistSuccess;

  @override
  State<ServiceCatalogEditorFormBody> createState() =>
      _ServiceCatalogEditorFormBodyState();
}

class _ServiceCatalogEditorFormBodyState
    extends State<ServiceCatalogEditorFormBody> {
  late final TextEditingController _nomeController;
  late final TextEditingController _valorController;
  late final TextEditingController _obsController;
  late bool _maisUtilizado;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final ServiceCatalogItem? e = widget.existing;
    _nomeController = TextEditingController(text: e?.nome ?? '');
    _valorController = TextEditingController(
      text:
          e != null
              ? AppFormatters.formatCurrencyInputFromCentavos(
                (e.valorPadrao * 100).round(),
              )
              : '',
    );
    _obsController = TextEditingController(text: e?.observacao ?? '');
    _maisUtilizado = e?.isMaisUtilizado ?? false;
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
    setState(() {
      _saving = true;
    });
    final String obs = _obsController.text.trim();
    final Either<Failure, ServiceCatalogItem> result = await widget.onPersist(
      nome: nome,
      valorPadrao: valor,
      observacao: obs.isEmpty ? null : obs,
      isMaisUtilizado: _maisUtilizado,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
    });
    await result.fold(
      (Failure failure) async {
        AppSnackbar.showError(failure.message);
      },
      (ServiceCatalogItem _) async {
        if (widget.afterPersistSuccess != null) {
          await widget.afterPersistSuccess!();
        }
        if (!mounted) {
          return;
        }
        AppSnackbar.showSuccess('Serviço salvo.');
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ServiceCatalogItem? e = widget.existing;
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Text(
                  e == null ? 'Novo serviço' : 'Editar serviço',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ServiceDetailFormFields(
                  nomeController: _nomeController,
                  valorController: _valorController,
                  observacaoController: _obsController,
                  isLoading: _saving,
                  onPrimaryPressed: _save,
                  nomeHintText: 'Ex: Lavagem de motor',
                  valorFieldLabel: 'Valor padrão',
                  obsFieldLabel: 'Observações (opcional)',
                  obsHintText: 'Observações (opcional)',
                  primaryButtonLabel: 'Salvar',
                  showPrimaryIcon: false,
                  obsMinLines: 2,
                  obsMaxLines: 4,
                  beforePrimaryButton: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sugestões rápidas (até 3)'),
                    subtitle: const Text('Aparece como chip no atendimento.'),
                    value: _maisUtilizado,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.45),
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
    );
  }
}

/// Service name, value, observations, and primary add action (expandable card).
class ServiceDetailForm extends StatefulWidget {
  const ServiceDetailForm({
    super.key,
    required this.nomeController,
    required this.valorController,
    required this.observacaoController,
    required this.isLoading,
    required this.onAddToService,
  });

  final TextEditingController nomeController;
  final TextEditingController valorController;
  final TextEditingController observacaoController;
  final bool isLoading;
  final VoidCallback onAddToService;

  @override
  State<ServiceDetailForm> createState() => _ServiceDetailFormState();
}

class _ServiceDetailFormState extends State<ServiceDetailForm> {
  late final ExpansibleController _expansionTileController;

  @override
  void initState() {
    super.initState();
    _expansionTileController = ExpansibleController();
  }

  @override
  void dispose() {
    _expansionTileController.dispose();
    super.dispose();
  }

  void _executeAddToService() {
    _expansionTileController.collapse();
    widget.onAddToService();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 12,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: ExpansionTile(
            controller: _expansionTileController,
            initiallyExpanded: true,
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent),
            ),
            collapsedShape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent),
            ),
            title: RichText(
              text: TextSpan(
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
                children: <TextSpan>[
                  const TextSpan(text: 'Detalhamento do '),
                  TextSpan(
                    text: 'Serviço',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    ServiceDetailFormFields(
                      nomeController: widget.nomeController,
                      valorController: widget.valorController,
                      observacaoController: widget.observacaoController,
                      isLoading: widget.isLoading,
                      onPrimaryPressed: _executeAddToService,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
