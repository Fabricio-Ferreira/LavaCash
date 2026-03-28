import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lava_cash/app/theme/app_colors.dart';
import 'package:lava_cash/core/utils/brazilian_real_input_formatter.dart';

/// Service name, value, observations, and primary add action.
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

  static const InputBorder _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isLoading = widget.isLoading;
    final Color fillColor = AppColors.surfaceContainerHigh.withValues(
      alpha: 0.55,
    );
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
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent),
            ),
            // Remove a borda/linha superior e inferior quando FECHADO
            collapsedShape: RoundedRectangleBorder(
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
                    Text(
                      'Nome do serviço',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: widget.nomeController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ex: Lavagem de carro',
                        hintStyle: textTheme.bodyLarge?.copyWith(
                          color: AppColors.outline,
                        ),
                        filled: true,
                        fillColor: fillColor,
                        border: _fieldBorder,
                        enabledBorder: _fieldBorder,
                        focusedBorder: _fieldBorder,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Valor do Serviço',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: widget.valorController,
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
                        border: _fieldBorder,
                        enabledBorder: _fieldBorder,
                        focusedBorder: _fieldBorder,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Observações (Opcional)',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: widget.observacaoController,
                      minLines: 3,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Detalhes adicionais sobre o procedimento...',
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: AppColors.outline,
                        ),
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: fillColor,
                        border: _fieldBorder,
                        enabledBorder: _fieldBorder,
                        focusedBorder: _fieldBorder,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isLoading ? null : _executeAddToService,
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
                                  Text(
                                    'Adicionar ao atendimento',
                                    style: textTheme.titleSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
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
