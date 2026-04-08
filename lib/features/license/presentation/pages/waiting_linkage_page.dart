import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/waiting_linkage_activation_card.dart';
import '../widgets/waiting_linkage_intro_section.dart';

/// Shown when the device has a valid license but could not claim empresa
/// and has no nome to create one — operador must share activation code with admin.
class WaitingLinkagePage extends StatefulWidget {
  const WaitingLinkagePage({super.key});

  @override
  State<WaitingLinkagePage> createState() => _WaitingLinkagePageState();
}

class _WaitingLinkagePageState extends State<WaitingLinkagePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeIntro;
  late final Animation<double> _fadeCard;
  late final Animation<Offset> _slideIntro;
  late final Animation<Offset> _slideCard;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _fadeIntro = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    _fadeCard = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
    );
    _slideIntro = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _slideCard = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _retryAfterAdminRegisteredInvite() {
    Get.offAllNamed<void>(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final AppGlobalController global = Get.find<AppGlobalController>();
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 56),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          FadeTransition(
                            opacity: _fadeIntro,
                            child: SlideTransition(
                              position: _slideIntro,
                              child: const WaitingLinkageIntroSection(),
                            ),
                          ),
                          const SizedBox(height: 28),
                          FadeTransition(
                            opacity: _fadeCard,
                            child: SlideTransition(
                              position: _slideCard,
                              child: Obx(() {
                                return WaitingLinkageActivationCard(
                                  activationCode: global.activationCode.value,
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Depois que o administrador cadastrar este código em '
                            '"Gerenciar usuários", toque abaixo para tentar de novo.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.outlineVariant,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: _retryAfterAdminRegisteredInvite,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Tentar novamente'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.45),
                              ),
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
