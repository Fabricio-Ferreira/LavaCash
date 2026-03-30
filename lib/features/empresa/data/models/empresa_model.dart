import '../../domain/entities/empresa.dart';

class EmpresaModel {
  const EmpresaModel({
    required this.id,
    required this.nome,
    this.telefone,
    required this.activationCode,
    this.ownerId,
  });

  final String id;
  final String nome;
  final String? telefone;
  final String activationCode;
  final String? ownerId;

  factory EmpresaModel.fromJson(Map<String, dynamic> json) {
    return EmpresaModel(
      id: json['id'] as String,
      nome: json['nome'] as String? ?? '',
      telefone: json['telefone'] as String?,
      activationCode: json['activation_code'] as String? ?? '',
      ownerId: json['owner_id'] as String?,
    );
  }

  Empresa toDomain() {
    return Empresa(
      id: id,
      nome: nome,
      telefone: telefone,
      activationCode: activationCode,
      ownerId: ownerId,
    );
  }
}
