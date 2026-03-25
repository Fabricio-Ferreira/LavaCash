enum ServiceStatus { emAndamento, finalizado, cancelado }

extension ServiceStatusX on ServiceStatus {
  String get dbValue {
    switch (this) {
      case ServiceStatus.emAndamento:
        return 'em_andamento';
      case ServiceStatus.finalizado:
        return 'finalizado';
      case ServiceStatus.cancelado:
        return 'cancelado';
    }
  }

  static ServiceStatus? fromDb(String? value) {
    if (value == null) {
      return null;
    }
    for (final ServiceStatus s in ServiceStatus.values) {
      if (s.dbValue == value) {
        return s;
      }
    }
    return null;
  }

  String get labelPt {
    switch (this) {
      case ServiceStatus.emAndamento:
        return 'Em andamento';
      case ServiceStatus.finalizado:
        return 'Finalizado';
      case ServiceStatus.cancelado:
        return 'Cancelado';
    }
  }
}
