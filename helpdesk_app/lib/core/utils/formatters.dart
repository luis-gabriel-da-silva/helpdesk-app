class Formatters {
  /// Formata uma data [DateTime] para o formato dd/mm/aaaa hh:mm
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year às $hour:$minute';
  }

  /// Converte a categoria para um texto amigável na UI
  static String formatCategory(String category) {
    switch (category) {
      case 'hardware':
        return 'Hardware';
      case 'login':
        return 'Login / Acesso';
      case 'db_infra':
        return 'Banco de Dados / Infra';
      case 'financeiro':
        return 'Financeiro';
      default:
        return category;
    }
  }

  /// Converte o status para um texto amigável na UI
  static String formatStatus(String status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'em_andamento':
        return 'Em Andamento';
      case 'concluido':
        return 'Concluído';
      default:
        return status;
    }
  }
}
