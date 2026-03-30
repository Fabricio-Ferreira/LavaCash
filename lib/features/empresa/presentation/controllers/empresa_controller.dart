import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../app/app_global_controller.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/empresa.dart';
import '../../domain/repositories/empresa_repository.dart';

class EmpresaController extends GetxController {
  EmpresaController({required EmpresaRepository empresaRepository})
      : _empresaRepository = empresaRepository;

  final EmpresaRepository _empresaRepository;

  final Rxn<Empresa> empresa = Rxn<Empresa>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  /// Verifica se empresa já existe; se não, tenta reivindicar pelo activation_code.
  /// Retorna true se empresa foi encontrada ou reivindicada com sucesso.
  Future<bool> loadOrClaim(String activationCode) async {
    isLoading.value = true;
    errorMessage.value = null;
    final Either<Failure, Empresa?> fetchResult =
        await _empresaRepository.fetchOwn();
    final Empresa? existing = fetchResult.fold((_) => null, (e) => e);
    if (existing != null) {
      log('EmpresaController | empresa existente id=${existing.id}');
      empresa.value = existing;
      _populateGlobal(existing);
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
    isLoading.value = false;
    return claimResult.fold(
      (Failure failure) {
        log('EmpresaController | claim falhou: ${failure.message}');
        errorMessage.value = failure.message;
        return false;
      },
      (Empresa? claimed) {
        if (claimed == null) {
          log('EmpresaController | activation_code inválido ou já reivindicado');
          return false;
        }
        log('EmpresaController | claim OK id=${claimed.id}');
        empresa.value = claimed;
        _populateGlobal(claimed);
        return true;
      },
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
      (Empresa created) {
        empresa.value = created;
        _populateGlobal(created);
        return true;
      },
    );
  }

  void _populateGlobal(Empresa e) {
    final AppGlobalController global = Get.find<AppGlobalController>();
    global.empresaId.value = e.id;
    if (global.establishmentName.value.isEmpty) {
      global.establishmentName.value = e.nome;
    }
  }
}
