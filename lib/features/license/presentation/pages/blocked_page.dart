import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/utils/constants.dart';
import '../widgets/blocked_activation_card.dart';
import '../widgets/blocked_brand_logo_block.dart';
import '../widgets/blocked_glass_app_header.dart';

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BlockedGlassAppHeader(),
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
                              const BlockedBrandLogoBlock(),
                              const SizedBox(height: 32),
                              BlockedActivationCard(
                                activationKeyController:
                                    _activationKeyController,
                                onActivate: _retryLicenseCheck,
                                onWhatsApp: () =>
                                    _openWhatsAppSupport(global),
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
