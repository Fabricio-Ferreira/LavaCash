import 'package:flutter/material.dart';
import 'package:lava_cash/core/utils/app_snackbar.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../features/auth/domain/entities/user_role.dart';
import 'convite_role_option.dart';

class AddConviteBottomSheet extends StatefulWidget {
  const AddConviteBottomSheet({super.key});

  @override
  State<AddConviteBottomSheet> createState() => _AddConviteBottomSheetState();
}

class _AddConviteBottomSheetState extends State<AddConviteBottomSheet> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  UserRole _selectedRole = UserRole.operador;

  @override
  void dispose() {
    _codeController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedRole == UserRole.operador &&
        _nomeController.text.trim().isEmpty) {
      AppSnackbar.showInfo('Informe o nome do funcionário.');
      return;
    }
    final String code = _codeController.text.trim();
    final String? membroNome =
        _selectedRole == UserRole.operador ? _nomeController.text.trim() : null;
    Navigator.of(
      context,
    ).pop((code: code, role: _selectedRole, membroNome: membroNome));
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Convidar dispositivo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Insira o código de ativação do dispositivo convidado.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Código de ativação',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              prefixIcon: const Icon(Icons.vpn_key_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nível de acesso',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              ConviteRoleOption(
                label: 'Operador',
                icon: Icons.person_outline,
                selected: _selectedRole == UserRole.operador,
                onTap: () => setState(() => _selectedRole = UserRole.operador),
              ),
              const SizedBox(width: 12),
              ConviteRoleOption(
                label: 'Admin',
                icon: Icons.manage_accounts,
                selected: _selectedRole == UserRole.admin,
                onTap: () => setState(() => _selectedRole = UserRole.admin),
              ),
            ],
          ),
          if (_selectedRole == UserRole.operador) ...<Widget>[
            const SizedBox(height: 16),
            TextField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Nome do funcionário',
                hintText: 'Como aparecerá na lista de usuários',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.send_outlined),
            label: const Text('Enviar convite'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
