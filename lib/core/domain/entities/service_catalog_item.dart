import 'package:equatable/equatable.dart';

class ServiceCatalogItem extends Equatable {
  const ServiceCatalogItem({
    required this.id,
    required this.nome,
    required this.valorPadrao,
    this.observacao,
    required this.isMaisUtilizado,
    required this.isDeleted,
  });

  final String id;
  final String nome;
  final double valorPadrao;
  final String? observacao;
  final bool isMaisUtilizado;
  final bool isDeleted;

  @override
  List<Object?> get props => <Object?>[
    id,
    nome,
    valorPadrao,
    observacao,
    isMaisUtilizado,
    isDeleted,
  ];
}
