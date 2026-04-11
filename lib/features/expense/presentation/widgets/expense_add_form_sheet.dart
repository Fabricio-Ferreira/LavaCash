import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/brazilian_real_input_formatter.dart';
import '../../../../core/utils/formatters.dart';
import 'package:lava_cash/core/domain/expense/entities/expense.dart';
import '../expense_category_labels.dart';

class ExpenseAddFormSheet extends StatefulWidget {
  const ExpenseAddFormSheet({
    super.key,
    required this.onSubmit,
    this.editing,
  });

  final Expense? editing;
  final Future<void> Function({
    required String descricao,
    required String categoria,
    required double valor,
  })
  onSubmit;

  @override
  State<ExpenseAddFormSheet> createState() => _ExpenseAddFormSheetState();
}

class _ExpenseAddFormSheetState extends State<ExpenseAddFormSheet> {
  final TextEditingController _descricao = TextEditingController();
  final TextEditingController _valor = TextEditingController();
  late List<String> _categoriaKeys;
  late String _categoria;

  @override
  void initState() {
    super.initState();
    _categoriaKeys = List<String>.from(ExpenseCategoryLabels.keys);
    final Expense? e = widget.editing;
    if (e != null) {
      if (!_categoriaKeys.contains(e.categoria)) {
        _categoriaKeys = <String>[..._categoriaKeys, e.categoria];
      }
      _categoria = e.categoria;
      _descricao.text = e.descricao;
      _valor.text = AppFormatters.formatCurrencyInputFromCentavos(
        (e.valor * 100).round(),
      );
    } else {
      _categoria = ExpenseCategoryLabels.keys.first;
    }
  }

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final double? v = AppFormatters.parseMoneyInput(_valor.text);
    if (v == null || v <= 0) {
      AppSnackbar.showError('Informe um valor válido.');
      return;
    }
    await widget.onSubmit(
      descricao: _descricao.text,
      categoria: _categoria,
      valor: v,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isEditing = widget.editing != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEditing ? 'Editar despesa' : 'Nova despesa',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descricao,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _categoria,
                  isExpanded: true,
                  items: _categoriaKeys
                      .map(
                        (String k) => DropdownMenuItem<String>(
                          value: k,
                          child: Text(ExpenseCategoryLabels.displayName(k)),
                        ),
                      )
                      .toList(),
                  onChanged: (String? v) {
                    if (v != null) {
                      setState(() {
                        _categoria = v;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valor,
              keyboardType: TextInputType.number,
              inputFormatters: const <TextInputFormatter>[
                BrazilianRealInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(),
                hintText: '0,00',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? 'Salvar alterações' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
