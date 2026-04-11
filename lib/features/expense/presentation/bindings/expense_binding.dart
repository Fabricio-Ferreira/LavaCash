import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_initializer.dart';
import 'package:lava_cash/core/data/expense/repositories/expense_repository_impl.dart';
import 'package:lava_cash/core/domain/expense/repositories/expense_repository.dart';
import 'package:lava_cash/core/domain/expense/usecases/create_expense.dart';
import 'package:lava_cash/core/domain/expense/usecases/delete_expense.dart';
import 'package:lava_cash/core/domain/expense/usecases/list_expenses_in_range.dart';
import 'package:lava_cash/core/domain/expense/usecases/update_expense.dart';
import '../controllers/expense_controller.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    final SupabaseClient? client = SupabaseInitializer.clientOrNull;
    Get.lazyPut<ExpenseRepository>(
      () => ExpenseRepositoryImpl(client: client),
      fenix: true,
    );
    Get.lazyPut<ListExpensesInRange>(
      () => ListExpensesInRange(repository: Get.find<ExpenseRepository>()),
      fenix: true,
    );
    Get.lazyPut<CreateExpense>(
      () => CreateExpense(repository: Get.find<ExpenseRepository>()),
      fenix: true,
    );
    Get.lazyPut<UpdateExpense>(
      () => UpdateExpense(repository: Get.find<ExpenseRepository>()),
      fenix: true,
    );
    Get.lazyPut<DeleteExpense>(
      () => DeleteExpense(repository: Get.find<ExpenseRepository>()),
      fenix: true,
    );
    Get.lazyPut<ExpenseController>(
      () => ExpenseController(
        listExpensesInRange: Get.find<ListExpensesInRange>(),
        createExpense: Get.find<CreateExpense>(),
        updateExpense: Get.find<UpdateExpense>(),
        deleteExpense: Get.find<DeleteExpense>(),
      ),
      fenix: true,
    );
  }
}
