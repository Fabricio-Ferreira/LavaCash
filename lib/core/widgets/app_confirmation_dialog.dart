import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lava_cash/app/theme/app_colors.dart';

/// Reusable confirmation dialog (GetX route). Returns `true` if confirmed.
abstract class AppDialog {
  /// Shows [AlertDialog] with cancel / confirm. Confirm uses destructive
  /// styling when [confirmIsDestructive] is true.
  static Future<bool?> show({
    required String title,
    required String message,
    String cancelLabel = 'Voltar',
    String confirmLabel = 'Confirmar',
    bool barrierDismissible = false,
    bool confirmIsDestructive = false,
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style:
                confirmIsDestructive
                    ? FilledButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                      foregroundColor: Colors.white,
                    )
                    : null,
            onPressed: () => Get.back<bool>(result: true),
            child: Text(confirmLabel),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}
