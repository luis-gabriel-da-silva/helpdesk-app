import 'package:flutter/foundation.dart';

const _configuredWebApiBaseUrl = String.fromEnvironment('API_BASE_URL');

class ApiConfig {
  // Ajusta automaticamente o IP dependendo da plataforma
  static String get baseUrl {
    if (kIsWeb) {
      return _configuredWebApiBaseUrl.isNotEmpty
          ? _configuredWebApiBaseUrl
          : 'http://localhost:8000/api'; // Para navegador local ou build Docker
    } else {
      // Para emulador Android
      return 'http://10.0.2.2:8000/api';
    }
  }

  static String resolveMediaUrl(String url) {
    final mediaUri = Uri.tryParse(url);
    if (mediaUri == null) return url;

    final localHosts = {'localhost', '127.0.0.1', '0.0.0.0'};
    if (!localHosts.contains(mediaUri.host.toLowerCase())) return url;

    final apiUri = Uri.parse(baseUrl);
    return mediaUri
        .replace(
          scheme: apiUri.scheme,
          host: apiUri.host,
          port: apiUri.hasPort ? apiUri.port : null,
        )
        .toString();
  }

  // Endpoints de autenticação
  static String get loginUrl => '$baseUrl/login';
  static String get logoutUrl => '$baseUrl/logout';
  static String get profileUrl => '$baseUrl/profile';

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
