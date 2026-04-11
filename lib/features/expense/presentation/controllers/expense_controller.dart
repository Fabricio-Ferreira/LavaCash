import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../license/presentation/services/license_status_refresh.dart';
import '../../../reports/presentation/controllers/report_controller.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/create_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/list_expenses_in_range.dart';
import '../../domain/usecases/update_expense.dart';

class ExpenseController extends GetxController {
  ExpenseController({
    required ListExpensesInRange listExpensesInRange,
    required CreateExpense createExpense,
    required UpdateExpense updateExpense,
    required DeleteExpense deleteExpense,
  }) : _listExpensesInRange = listExpensesInRange,
       _createExpense = createExpense,
       _updateExpense = updateExpense,
       _deleteExpense = deleteExpense;

  final ListExpensesInRange _listExpensesInRange;
  final CreateExpense _createExpense;
  final UpdateExpense _updateExpense;
  final DeleteExpense _deleteExpense;

  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final RxList<Expense> items = <Expense>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    errorMessage.value = '';
    final bool licenseOk = await LicenseStatusRefresh.verifyAndSyncOrExit();
    if (!licenseOk) {
      return;
    }
    isLoading.value = true;
    final DateTime d = selectedDay.value;
    final DateTime start = DateTime(d.year, d.month, d.day);
    final DateTime end = DateTime(d.year, d.month, d.day);
    final Either<Failure, List<Expense>> result = await _listExpensesInRange(
      startInclusive: start,
      endInclusive: end,
    );
    result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
      },
      (List<Expense> list) {
        items.assignAll(list);
      },
    );
    isLoading.value = false;
  }

  void setSelectedDay(DateTime day) {
    selectedDay.value = DateTime(day.year, day.month, day.day);
    load();
  }

  void _notifyDailyReportIfPossible() {
    if (!Get.isRegistered<ReportController>()) {
      return;
    }
    Get.find<ReportController>().loadDaily();
  }

  Future<void> deleteExpense(Expense expense) async {
    final Either<Failure, Unit> result = await _deleteExpense(expense.id);
    result.fold(
      (Failure failure) {
        AppSnackbar.showError(failure.message);
      },
      (_) {
        items.removeWhere((Expense e) => e.id == expense.id);
        AppSnackbar.showSuccess('Despesa removida.');
        _notifyDailyReportIfPossible();
      },
    );
  }

  Future<void> submitNewExpense({
    required String descricao,
    required String categoria,
    required double valor,
  }) async {
    errorMessage.value = '';
    if (descricao.trim().isEmpty) {
      AppSnackbar.showError('Informe a descrição.');
      return;
    }
    if (valor <= 0) {
      AppSnackbar.showError('Informe um valor maior que zero.');
      return;
    }
    final Either<Failure, Expense> result = await _createExpense(
      descricao: descricao,
      categoria: categoria,
      valor: valor,
      dataReferencia: selectedDay.value,
    );
    result.fold(
      (Failure failure) {
        AppSnackbar.showError(failure.message);
      },
      (Expense created) {
        items.insert(0, created);
        Get.back<void>();
        AppSnackbar.showSuccess('Despesa registrada.');
        _notifyDailyReportIfPossible();
      },
    );
  }

  Future<void> submitExpenseUpdate({
    required String id,
    required String descricao,
    required String categoria,
    required double valor,
  }) async {
    errorMessage.value = '';
    if (descricao.trim().isEmpty) {
      AppSnackbar.showError('Informe a descrição.');
      return;
    }
    if (valor <= 0) {
      AppSnackbar.showError('Informe um valor maior que zero.');
      return;
    }
    final Either<Failure, Expense> result = await _updateExpense(
      id: id,
      descricao: descricao,
      categoria: categoria,
      valor: valor,
    );
    result.fold(
      (Failure failure) {
        AppSnackbar.showError(failure.message);
      },
      (Expense updated) {
        final int idx = items.indexWhere((Expense e) => e.id == id);
        if (idx >= 0) {
          items[idx] = updated;
          items.refresh();
        } else {
          load();
        }
        Get.back<void>();
        AppSnackbar.showSuccess('Despesa atualizada.');
        _notifyDailyReportIfPossible();
      },
    );
  }
}
