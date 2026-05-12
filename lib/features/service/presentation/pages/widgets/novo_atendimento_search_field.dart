import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/plate_or_name_search_input_formatter.dart';

class NovoAtendimentoSearchField extends StatelessWidget {
  const NovoAtendimentoSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      inputFormatters: <TextInputFormatter>[
        PlateOrNameSearchInputFormatter(),
      ],
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        hintText: 'Buscar por placa ou nome',
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.outline.withValues(alpha: 0.6),
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.outline),
        filled: true,
        fillColor: AppColors.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
