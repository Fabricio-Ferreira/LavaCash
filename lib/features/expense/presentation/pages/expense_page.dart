import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/expense.dart';
import '../controllers/expense_controller.dart';
import '../widgets/expense_add_form_sheet.dart';
import '../widgets/expense_date_selector_row.dart';
import '../widgets/expense_list_item_card.dart';
import '../widgets/expense_total_day_card.dart';

class ExpensePage extends GetView<ExpenseController> {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.receipt_long),
        label: const Text('Nova despesa'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back<void>(),
            ),
            title: Text(
              'Despesas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.onSurface,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            sliver: SliverToBoxAdapter(
              child: Obx(() {
                final DateTime day = controller.selectedDay.value;
                final bool loading = controller.isLoading.value;
                final double total = controller.items.fold<double>(
                  0,
                  (double a, Expense b) => a + b.valor,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ExpenseDateSelectorRow(
                      day: day,
                      onPickDate: () => _pickDate(context),
                    ),
                    const SizedBox(height: 16),
                    ExpenseTotalDayCard(total: total),
                    const SizedBox(height: 16),
                    SelectableText.rich(
                      TextSpan(
                        text:
                            controller.errorMessage.value.isEmpty
                                ? ''
                                : controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (controller.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'Nenhuma despesa neste dia.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ...controller.items.map(
                        (Expense e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ExpenseListItemCard(
                            expense: e,
                            onEdit: () => _openEditSheet(context, e),
                            onDelete: () => _confirmDelete(context, e),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime initial = controller.selectedDay.value;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      controller.setSelectedDay(picked);
    }
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: ExpenseAddFormSheet(
            onSubmit: ({
              required String descricao,
              required String categoria,
              required double valor,
            }) async {
              await controller.submitNewExpense(
                descricao: descricao,
                categoria: categoria,
                valor: valor,
              );
            },
          ),
        );
      },
    );
  }

  void _openEditSheet(BuildContext context, Expense expense) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: ExpenseAddFormSheet(
            editing: expense,
            onSubmit: ({
              required String descricao,
              required String categoria,
              required double valor,
            }) async {
              await controller.submitExpenseUpdate(
                id: expense.id,
                descricao: descricao,
                categoria: categoria,
                valor: valor,
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Expense expense) async {
    final bool? ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remover despesa'),
        content: Text(
          'Excluir "${expense.descricao}" (${AppFormatters.formatCurrency(expense.valor)})?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Get.back<bool>(result: true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.deleteExpense(expense);
    }
  }
}
