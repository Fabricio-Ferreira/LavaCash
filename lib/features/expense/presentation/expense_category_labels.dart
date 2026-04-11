/// UI labels for [Expense.categoria] keys stored in the database.
abstract class ExpenseCategoryLabels {
  static String displayName(String categoria) {
    switch (categoria) {
      case 'produtos':
        return 'Produtos / insumos';
      case 'funcionarios':
        return 'Funcionários';
      case 'utilidades':
        return 'Utilidades';
      case 'manutencao':
        return 'Manutenção';
      case 'outros':
        return 'Outros';
      default:
        return categoria;
    }
  }

  static const List<String> keys = <String>[
    'produtos',
    'funcionarios',
    'utilidades',
    'manutencao',
    'outros',
  ];
}
