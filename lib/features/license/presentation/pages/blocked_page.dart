import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/utils/constants.dart';

class BlockedPage extends StatefulWidget {
  const BlockedPage({super.key});

  @override
  State<BlockedPage> createState() => _BlockedPageState();
}

class _BlockedPageState extends State<BlockedPage> {
  final TextEditingController _activationKeyController =
      TextEditingController();

  @override
  void dispose() {
    _activationKeyController.dispose();
    super.dispose();
  }

  Future<void> _openWhatsAppSupport(AppGlobalController global) async {
    final String digits = AppConstants.licenseSupportWhatsAppDigits;
    final String deviceId = global.deviceId.value;
    final String key = _activationKeyController.text.trim();
    final StringBuffer body = StringBuffer(
      'Olá! Preciso de ajuda para ativar o LavaCash.',
    );
    if (deviceId.isNotEmpty) {
      body.write('\nDevice ID: $deviceId');
    }
    if (key.isNotEmpty) {
      body.write('\nChave informada: $key');
    }
    if (digits.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'WhatsApp de suporte não configurado (AppConstants).',
          ),
        ),
      );
      return;
    }
    await WhatsAppService.openChatWithPrefilledText(
      phoneDigitsOnly: digits,
      message: body.toString(),
    );
  }

  void _retryLicenseCheck() {
    Get.offAllNamed<void>(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final AppGlobalController global = Get.find<AppGlobalController>();
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            // const _RevenueWatermark(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _GlassAppHeader(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                    ) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 64,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const _BrandLogoBlock(),
                              const SizedBox(height: 32),
                              _ActivationCard(
                                activationKeyController:
                                    _activationKeyController,
                                onActivate: _retryLicenseCheck,
                                onWhatsApp: () =>
                                    _openWhatsAppSupport(global),
                                deviceId: global.deviceId,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class _GlassAppHeader extends StatelessWidget {
  const _GlassAppHeader();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          
        ),
      ),
    );
  }
}

class _BrandLogoBlock extends StatelessWidget {
  const _BrandLogoBlock();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SvgPicture.asset(
            'assets/images/logo.svg',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'LavaCash',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Seu faturamento na palma da mão',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ActivationCard extends StatelessWidget {
  const _ActivationCard({
    required this.activationKeyController,
    required this.onActivate,
    required this.onWhatsApp,
    required this.deviceId,
  });

  final TextEditingController activationKeyController;
  final VoidCallback onActivate;
  final VoidCallback onWhatsApp;
  final RxString deviceId;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.secondaryContainer.withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.lock_person,
                size: 40,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Acesso temporariamente indisponível',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sua licença está inativa ou expirou. Se você tiver uma chave de '
            'ativação, digite abaixo para liberar o acesso.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'CHAVE DE ATIVAÇÃO',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: activationKeyController,
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            enableSuggestions: false,
            enableInteractiveSelection: true,
            smartDashesType: SmartDashesType.disabled,
            smartQuotesType: SmartQuotesType.disabled,
            decoration: InputDecoration(
              hintText: 'Digite sua chave de ativação',
              hintStyle: TextStyle(color: AppColors.outline),
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              suffixIcon: Icon(
                Icons.vpn_key,
                color: AppColors.outline,
              ),
            ),
          ),
          const SizedBox(height: 24),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.primary,
                  AppColors.primaryContainer,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onActivate,
                child: SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ativar aplicativo',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onWhatsApp,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Suporte no WhatsApp',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Se precisar, nosso suporte pode te ajudar a ativar o app '
            'rapidamente.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.outline,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),
       
        ],
      ),
    );
  }
}
