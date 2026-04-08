import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/supabase_initializer.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/empresa_usuario.dart';
import '../controllers/usuarios_controller.dart';
import 'widgets/add_convite_bottom_sheet.dart';
import 'widgets/usuario_list_tile.dart';
import 'widgets/usuarios_empty_state.dart';
import 'widgets/usuarios_error_state.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String empresaId = Get.find<AppGlobalController>().empresaId.value;
      Get.find<UsuariosController>().loadUsuarios(empresaId);
    });
  }

  String _currentUserId() {
    return SupabaseInitializer.clientOrNull?.auth.currentUser?.id ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final UsuariosController controller = Get.find<UsuariosController>();
    final AppGlobalController global = Get.find<AppGlobalController>();
    final String currentUserId = _currentUserId();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddConvite(controller, global),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text(
          'Convidar dispositivo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final String? error = controller.errorMessage.value;
        if (error != null) {
          return UsuariosErrorState(message: error);
        }
        final List<EmpresaUsuario> list = controller.usuarios;
        if (list.isEmpty) {
          return const UsuariosEmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 100),
          itemCount: list.length,
          itemBuilder: (_, int i) {
            final EmpresaUsuario usuario = list[i];
            return UsuarioListTile(
              usuario: usuario,
              isCurrentUser: usuario.userId == currentUserId,
              onChangeRole:
                  (UserRole role) => _changeRole(
                    controller,
                    global.empresaId.value,
                    usuario.userId,
                    role,
                  ),
              onRemove:
                  () => _confirmRemove(
                    controller,
                    global.empresaId.value,
                    usuario.userId,
                  ),
            );
          },
        );
      }),
    );
  }

  Future<void> _showAddConvite(
    UsuariosController controller,
    AppGlobalController global,
  ) async {
    final dynamic result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddConviteBottomSheet(),
    );
    if (result == null) return;
    final ({String code, UserRole role, String? memberName}) data =
        result as ({String code, UserRole role, String? memberName});
    if (data.code.isEmpty) return;
    final bool ok = await controller.addConvite(
      empresaId: global.empresaId.value,
      activationCode: data.code,
      role: data.role,
      membroNome: data.memberName,
    );
    if (mounted) {
      final String msg =
          ok
              ? 'Convite enviado!'
              : (controller.errorMessage.value ?? 'Erro ao enviar convite.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: ok ? AppColors.primary : Colors.red,
        ),
      );
    }
  }

  Future<void> _changeRole(
    UsuariosController controller,
    String empresaId,
    String userId,
    UserRole role,
  ) async {
    await controller.updateRole(
      userId: userId,
      empresaId: empresaId,
      role: role,
    );
  }

  Future<void> _confirmRemove(
    UsuariosController controller,
    String empresaId,
    String userId,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Remover acesso'),
            content: const Text(
              'Este dispositivo perderá acesso à empresa. Confirmar?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remover'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    await controller.removeUsuario(userId: userId, empresaId: empresaId);
  }
}
