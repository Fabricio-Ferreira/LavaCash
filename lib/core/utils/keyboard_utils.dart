import 'package:flutter/widgets.dart';

/// Dismisses the software keyboard by unfocusing the primary [FocusNode].
///
/// App-wide: the root [GetMaterialApp] `builder` in `app/app.dart` wraps the
/// navigator in a [GestureDetector] that calls [hideKeyboard] on tap.
abstract class AppKeyboardUtils {
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
