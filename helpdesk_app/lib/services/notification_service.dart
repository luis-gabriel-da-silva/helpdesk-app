import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_notification_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class NotificationSnapshot {
  final List<AppNotificationModel> notifications;
  final int unreadCount;

  const NotificationSnapshot(this.notifications, this.unreadCount);
}

class NotificationService {
  final AuthService _authService = AuthService();

  Future<NotificationSnapshot> getNotifications() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/notifications'),
      headers: ApiConfig.headers(token),
    );
    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar as notificações.');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (decoded['data'] as List? ?? const [])
        .map((item) => AppNotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return NotificationSnapshot(data, decoded['unread_count'] as int? ?? 0);
  }

  Future<void> markRead(int id) async {
    final token = await _authService.getToken();
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
      headers: ApiConfig.headers(token),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Não foi possível marcar a notificação como lida.');
    }
  }
}
