import '../../domain/entities/expense.dart';

class ExpenseModel {
  const ExpenseModel({
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

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data_referencia'];
    final DateTime dataReferencia = _parseDateOnly(rawData);
    final dynamic rawCreated = json['created_at'];
    final DateTime createdAt = rawCreated is String
        ? DateTime.parse(rawCreated).toLocal()
        : DateTime.now();
    return ExpenseModel(
      id: json['id'] as String,
      descricao: json['descricao'] as String,
      categoria: json['categoria'] as String? ?? 'outros',
      valor: _toDouble(json['valor']),
      dataReferencia: dataReferencia,
      createdAt: createdAt,
    );
  }

  Expense toDomain() {
    return Expense(
      id: id,
      descricao: descricao,
      categoria: categoria,
      valor: valor,
      dataReferencia: dataReferencia,
      createdAt: createdAt,
    );
  }

  static DateTime _parseDateOnly(dynamic raw) {
    if (raw == null) {
      return DateTime.now();
    }
    if (raw is DateTime) {
      return DateTime(raw.year, raw.month, raw.day);
    }
    final String s = raw.toString();
    final List<String> parts = s.split('T').first.split('-');
    if (parts.length == 3) {
      final int y = int.parse(parts[0]);
      final int m = int.parse(parts[1]);
      final int d = int.parse(parts[2]);
      return DateTime(y, m, d);
    }
    return DateTime.parse(s).toLocal();
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
