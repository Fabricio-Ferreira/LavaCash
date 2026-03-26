import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_colors.dart';

class RegistrationLabeledField extends StatelessWidget {
  const RegistrationLabeledField({
    super.key,
    required this.controller,
    required this.labelUppercase,
    required this.hint,
    required this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String labelUppercase;
  final String hint;
  final IconData suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  static const double _labelLetterSpacing = 0.6;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelUppercase,
          style: textTheme.labelSmall?.copyWith(
            letterSpacing: _labelLetterSpacing,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: Icon(suffixIcon, color: AppColors.outline, size: 22),
          ),
        ),
      ],
    );
  }
}
