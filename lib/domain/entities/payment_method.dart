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
