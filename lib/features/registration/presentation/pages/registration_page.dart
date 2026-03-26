import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../controllers/registration_controller.dart';
import 'widgets/registration_form_section.dart';
import 'widgets/registration_header.dart';
import 'widgets/registration_info_card.dart';
import 'widgets/registration_submit_button.dart';

class RegistrationPage extends GetView<RegistrationController> {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const RegistrationHeader(),
                  RegistrationFormSection(controller: controller),
                  const RegistrationInfoCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          RegistrationSubmitButton(controller: controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppBar(
      title: Text(
        'Novo cliente',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: RichText(
              text: TextSpan(
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                children: const <TextSpan>[
                  TextSpan(
                    text: 'Lava',
                    style: TextStyle(color: AppColors.onSurface),
                  ),
                  TextSpan(
                    text: 'Cash',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
