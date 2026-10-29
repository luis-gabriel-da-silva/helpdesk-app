import 'ticket_message_model.dart';
import 'user_model.dart';

class TicketModel {
  final int id;
  final String title;
  final String category; // 'hardware', 'login', 'db_infra', 'financeiro'
  final String status; // 'pendente', 'em_andamento', 'concluido'
  final String priority; // 'baixa', 'media', 'alta'
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user;
  final UserModel? technician;
  final List<TicketMessageModel> messages;

  TicketModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.technician,
    this.messages = const [],
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      technician: json['technician'] != null
          ? UserModel.fromJson(json['technician'])
          : null,
      messages: json['messages'] != null
          ? (json['messages'] as List)
                .map((m) => TicketMessageModel.fromJson(m))
                .toList()
          : [],
    );
  }
}
