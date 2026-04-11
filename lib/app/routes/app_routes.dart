abstract class AppRoutes {
  static const String splash = '/splash';
  static const String blocked = '/blocked';
  static const String home = '/home';
  static const String registration = '/registration';
  static const String novoAtendimento = '/novo-atendimento';
  static const String service = '/service';
  static const String payment = '/payment';

  /// Lista de atendimentos em andamento (filtro opcional).
  ///
  /// Passe o filtro com GetX:
  /// `Get.toNamed(AppRoutes.inProgressServices, arguments: ServiceStatus.emAndamento)`
  /// ou `arguments: null` para todos os itens retornados pelo backend.
  static const String inProgressServices = '/in-progress-services';

  /// Relatório diário. Opcional: `arguments` como [DateTime] (calendário do dia).
  static const String dailyReport = '/daily-report';

  /// Relatório mensal. Opcional: `arguments` como [DateTime] (usa ano/mês).
  static const String monthlyReport = '/monthly-report';

  /// Relatório por intervalo. Opcional: `arguments` como `Map` com
  /// `start` e `end` [DateTime] (inclusivas).
  static const String intervalReport = '/interval-report';

  static const String expenses = '/expenses';
}
