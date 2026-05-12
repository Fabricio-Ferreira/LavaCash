import 'package:flutter/material.dart';

import 'registration_page.dart';

/// Shell pushed via [Get.to] so the route generic matches [VehicleWithClient?].
/// The declarative route table uses `GetPage<dynamic>`, which yields
/// `GetPageRoute<dynamic>` and breaks typed `pushNamed` results.
class RegistrationFlowPage extends StatelessWidget {
  const RegistrationFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegistrationPage();
  }
}
