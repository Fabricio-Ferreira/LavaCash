import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.descricao,
    required this.categoria,
    required this.valor,
    required this.dataReferencia,
    required this.createdAt,
  });

  final String id;
  final String descricao;
  final String categoria;
  final double valor;
  final DateTime dataReferencia;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    descricao,
    categoria,
    valor,
    dataReferencia,
    createdAt,
  ];
}
