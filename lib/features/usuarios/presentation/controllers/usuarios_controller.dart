import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/empresa_usuario.dart';
import '../../domain/repositories/usuarios_repository.dart';

class UsuariosController extends GetxController {
  UsuariosController({required UsuariosRepository usuariosRepository})
    : _usuariosRepository = usuariosRepository;

  final UsuariosRepository _usuariosRepository;

  final RxList<EmpresaUsuario> usuarios = <EmpresaUsuario>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  Future<void> loadUsuarios(String empresaId) async {
    isLoading.value = true;
    errorMessage.value = null;
    final Either<Failure, List<EmpresaUsuario>> result =
        await _usuariosRepository.listUsuarios(empresaId);
    isLoading.value = false;
    result.fold(
      (Failure failure) {
        log('UsuariosController | listUsuarios falhou: ${failure.message}');
        errorMessage.value = failure.message;
      },
      (List<EmpresaUsuario> list) => usuarios.assignAll(list),
    );
  }

  Future<bool> updateRole({
    required String userId,
    required String empresaId,
    required UserRole role,
  }) async {
    final Either<Failure, Unit> result = await _usuariosRepository.updateRole(
      userId: userId,
      empresaId: empresaId,
      role: role,
    );
    return result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        return false;
      },
      (_) {
        final int idx = usuarios.indexWhere((u) => u.userId == userId);
        if (idx >= 0) {
          usuarios[idx] = usuarios[idx].copyWith(role: role);
        }
        return true;
      },
    );
  }

  Future<bool> removeUsuario({
    required String userId,
    required String empresaId,
  }) async {
    final Either<Failure, Unit> result = await _usuariosRepository
        .removeUsuario(userId: userId, empresaId: empresaId);
    return result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        return false;
      },
      (_) {
        usuarios.removeWhere((u) => u.userId == userId);
        return true;
      },
    );
  }

  Future<bool> addConvite({
    required String empresaId,
    required String activationCode,
    required UserRole role,
    String? membroNome,
  }) async {
    if (activationCode.trim().isEmpty) {
      errorMessage.value = 'Informe o código de ativação.';
      return false;
    }
    if (role == UserRole.operador &&
        (membroNome == null || membroNome.trim().isEmpty)) {
      errorMessage.value = 'Informe o nome do funcionário.';
      return false;
    }
    final Either<Failure, Unit> result = await _usuariosRepository.addConvite(
      empresaId: empresaId,
      activationCode: activationCode,
      role: role,
      membroNome: membroNome,
    );
    return result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        return false;
      },
      (_) => true,
    );
  }
}
