import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/app_global_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../services/whatsapp_service.dart';
import '../utils/constants.dart';
import '../utils/string_utils.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: topInset + 8,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Obx(() {
                final AppGlobalController global =
                    Get.find<AppGlobalController>();
                final String establishmentName = global.establishmentName.value;
                final String licenseType = global.licenseType.value;
                final String deviceId = global.deviceId.value;
                final String initials = AppStringUtils.extractInitials(
                  establishmentName,
                );
                final UserRole role = global.userRole.value;
                return Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          _InitialsAvatar(initials: initials),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GreetingColumn(
                              establishmentName: establishmentName,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (role.isAdmin)
                      IconButton(
                        icon: const Icon(Icons.group_outlined),
                        color: AppColors.primary,
                        tooltip: 'Gerenciar usuários',
                        onPressed: () => Get.toNamed<void>(AppRoutes.usuarios),
                      ),
                    _LicenseChip(
                      establishmentName: establishmentName,
                      licenseType: licenseType,
                      deviceId: deviceId,
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primaryContainer,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GreetingColumn extends StatelessWidget {
  const _GreetingColumn({required this.establishmentName});

  final String establishmentName;

  @override
  Widget build(BuildContext context) {
    final String greeting = AppStringUtils.resolveGreetingLine(DateTime.now());
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          greeting,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          establishmentName.isEmpty ? '—' : establishmentName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _LicenseChip extends StatelessWidget {
  const _LicenseChip({
    required this.establishmentName,
    required this.licenseType,
    required this.deviceId,
  });

  final String establishmentName;
  final String licenseType;
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    final String label =
        licenseType.trim().isEmpty
            ? 'Licença'
            : AppStringUtils.formatLicenseTypeLabel(licenseType);
    return ActionChip(
      avatar: Icon(
        Icons.workspace_premium_outlined,
        size: 18,
        color: AppColors.primary,
      ),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
      onPressed: () async {
        final String safeName =
            establishmentName.trim().isEmpty ? '—' : establishmentName;
        final String safeType = licenseType.trim().isEmpty ? '—' : licenseType;
        final String message =
            'Olá! Sou cliente LavaCash e gostaria de alterar o tipo da '
            'minha licença.\n'
            'Estabelecimento: $safeName\n'
            'Licença atual: $safeType\n'
            'Device ID: $deviceId';
        await WhatsAppService.openChatWithPrefilledText(
          phoneDigitsOnly: AppConstants.licenseSupportWhatsAppDigits,
          message: message,
        );
      },
    );
  }
}
