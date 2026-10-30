import '../constants/app_strings.dart';

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
        return AppStrings.catHardware;
      case 'login':
        return AppStrings.catLogin;
      case 'db_infra':
        return AppStrings.catDbInfra;
      case 'financeiro':
        return AppStrings.catFinanceiro;
      default:
        return category;
    }
  }

  /// Converte o status para um texto amigável na UI
  static String formatStatus(String status) {
    switch (status) {
      case 'pendente':
        return AppStrings.statusPending;
      case 'em_andamento':
        return AppStrings.statusInProgress;
      case 'concluido':
        return AppStrings.statusCompleted;
      default:
        return status;
    }
  }
}
