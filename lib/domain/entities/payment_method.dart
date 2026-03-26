import 'package:flutter/material.dart';

enum PaymentMethod { dinheiro, pix, debito, credito }

extension PaymentMethodX on PaymentMethod {
  String get dbValue {
    switch (this) {
      case PaymentMethod.dinheiro:
        return 'dinheiro';
      case PaymentMethod.pix:
        return 'pix';
      case PaymentMethod.debito:
        return 'debito';
      case PaymentMethod.credito:
        return 'credito';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.dinheiro:
        return 'Dinheiro';
      case PaymentMethod.pix:
        return 'PIX';
      case PaymentMethod.debito:
        return 'Débito';
      case PaymentMethod.credito:
        return 'Crédito';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.dinheiro:
        return Icons.attach_money;
      case PaymentMethod.pix:
        return Icons.pix;
      case PaymentMethod.debito:
        return Icons.credit_card;
      case PaymentMethod.credito:
        return Icons.credit_score;
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.dinheiro:
        return 'À vista';
      case PaymentMethod.pix:
        return 'Instantâneo';
      case PaymentMethod.debito:
        return 'Imediato';
      case PaymentMethod.credito:
        return 'Em até 1x';
    }
  }

  static PaymentMethod? fromDb(String? value) {
    if (value == null) {
      return null;
    }
    for (final PaymentMethod m in PaymentMethod.values) {
      if (m.dbValue == value) {
        return m;
      }
    }
    return null;
  }
}
