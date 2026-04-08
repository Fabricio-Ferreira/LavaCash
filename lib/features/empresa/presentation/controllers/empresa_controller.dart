import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/empresa.dart';
import '../../domain/repositories/empresa_repository.dart';

class EmpresaController extends GetxController {
  EmpresaController({required EmpresaRepository empresaRepository})
    : _empresaRepository = empresaRepository;

  final EmpresaRepository _empresaRepository;

  final Rxn<Empresa> empresa = Rxn<Empresa>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  /// True when claim/convite failed and there is no nome to create empresa —
  /// operador must ask admin to register this device's [activation_code].
  final RxBool isWaitingForCompanyLink = false.obs;

  /// Fetch own empresa via RLS (which now uses empresa_usuarios).
  /// Falls back to claim → convite → create.
  Future<bool> loadOrClaim(
    String activationCode, {
    String nomeParaCriacao = '',
    String telefoneParaCriacao = '',
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    isWaitingForCompanyLink.value = false;

    final Empresa? existing = (await _empresaRepository.fetchOwn()).fold(
      (_) => null,
      (e) => e,
    );
    if (existing != null) {
      log('EmpresaController | empresa existente id=${existing.id}');
      empresa.value = existing;
      await _populateGlobalWithRole(existing);
      isLoading.value = false;
      return true;
    }

    if (activationCode.isEmpty) {
      log('EmpresaController | sem empresa e sem activation_code');
      isLoading.value = false;
      return false;
    }

    log('EmpresaController | tentando claim code=$activationCode');
    final Either<Failure, Empresa?> claimResult =
        await _empresaRepository.claimByActivationCode(activationCode);

    if (claimResult.isRight()) {
      final Empresa? claimed = claimResult.fold((_) => null, (e) => e);
      if (claimed != null) {
        log('EmpresaController | claim OK id=${claimed.id}');
        empresa.value = claimed;
        await _registerAndPopulate(claimed, UserRole.admin);
        isLoading.value = false;
        return true;
      }
    }

    // Empresa already claimed — check if this device has a convite
    log('EmpresaController | verificando convite para code=$activationCode');
    final Empresa? convidada = (await _empresaRepository.acceptConvite(
      activationCode,
    )).fold((_) => null, (e) => e);

    if (convidada != null) {
      log('EmpresaController | convite aceito id=${convidada.id}');
      empresa.value = convidada;
      await _populateGlobalWithRole(convidada);
      isLoading.value = false;
      return true;
    }

    // Last resort: create new empresa
    final String nome = nomeParaCriacao.trim();
    if (nome.isEmpty) {
      log('EmpresaController | sem empresa, sem claim, sem convite, sem nome');
      isWaitingForCompanyLink.value = true;
      isLoading.value = false;
      return false;
    }

    log('EmpresaController | criando empresa após licença');
    return createEmpresa(
      nome: nome,
      telefone: telefoneParaCriacao.trim(),
      activationCode: activationCode,
    );
  }

  Future<bool> createEmpresa({
    required String nome,
    required String telefone,
    required String activationCode,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    final Either<Failure, Empresa> result = await _empresaRepository.create(
      nome: nome,
      telefone: telefone,
      activationCode: activationCode,
    );
    isLoading.value = false;
    return result.fold(
      (Failure failure) {
        errorMessage.value = failure.message;
        return false;
      },
      (Empresa created) async {
        empresa.value = created;
        await _registerAndPopulate(created, UserRole.admin);
        return true;
      },
    );
  }

  Future<void> _registerAndPopulate(Empresa e, UserRole role) async {
    await _empresaRepository.registerUserInEmpresa(
      empresaId: e.id,
      role: role,
    );
    _applyGlobal(e, role);
  }

  Future<void> _populateGlobalWithRole(Empresa e) async {
    final UserRole role = (await _empresaRepository.fetchMyRole()).fold(
      (_) => UserRole.operador,
      (r) => r ?? UserRole.operador,
    );
    _applyGlobal(e, role);
  }

  void _applyGlobal(Empresa e, UserRole role) {
    final AppGlobalController global = Get.find<AppGlobalController>();
    global.empresaId.value = e.id;
    global.userRole.value = role;
    if (global.establishmentName.value.isEmpty) {
      global.establishmentName.value = e.nome;
    }
  }
}
