import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/app_global_controller.dart';
import 'core/network/supabase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await SupabaseInitializer.ensureInitialized();
  Get.put<AppGlobalController>(AppGlobalController(), permanent: true);
  runApp(const LavaCashApp());
}
