import 'package:flutter/foundation.dart';

class ApiConfig {
  // Ajusta automaticamente o IP dependendo da plataforma
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api'; // Para navegadores Web
    } else {
      // Para emulador Android
      return 'http://10.0.2.2:8000/api';
    }
  }

  // Endpoints de autenticação
  static String get loginUrl => '$baseUrl/login';
  static String get logoutUrl => '$baseUrl/logout';

  // Endpoints de chamados (tickets)
  static String get ticketsUrl => '$baseUrl/tickets';
  static String ticketDetailUrl(int id) => '$baseUrl/tickets/$id';
  static String ticketMessagesUrl(int id) => '$baseUrl/tickets/$id/messages';
  static String ticketStatusUrl(int id) => '$baseUrl/tickets/$id/status';

  /// Gera os cabeçalhos padrão para as requisições HTTP da API
  static Map<String, String> headers([String? token]) {
    final Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headerMap['Authorization'] = 'Bearer $token';
    }

    return headerMap;
  }
}
