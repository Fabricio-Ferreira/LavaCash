import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_initializer.dart';
import 'package:lava_cash/core/data/payment/repositories/payment_repository_impl.dart';
import 'package:lava_cash/core/domain/payment/repositories/payment_repository.dart';
import 'package:lava_cash/core/domain/payment/usecases/complete_payment.dart';
import '../controllers/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    final SupabaseClient? client = SupabaseInitializer.clientOrNull;
    Get.lazyPut<PaymentRepository>(
      () => PaymentRepositoryImpl(client: client),
      fenix: true,
    );
    Get.lazyPut<CompletePayment>(
      () => CompletePayment(repository: Get.find<PaymentRepository>()),
      fenix: true,
    );
    Get.lazyPut<PaymentController>(
      () => PaymentController(completePayment: Get.find<CompletePayment>()),
      fenix: true,
    );
  }
}
