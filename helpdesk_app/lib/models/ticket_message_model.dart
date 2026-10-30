import 'user_model.dart';

class TicketMessageModel {
  final int id;
  final int ticketId;
  final String message;
  final String? attachmentUrl;
  final DateTime createdAt;
  final UserModel? user;

  TicketMessageModel({
    required this.id,
    required this.ticketId,
    required this.message,
    this.attachmentUrl,
    required this.createdAt,
    this.user,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    return TicketMessageModel(
      id: json['id'] as int,
      ticketId: json['ticket_id'] as int,
      message: json['message'] as String,
      attachmentUrl: json['attachment_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ticket_id': ticketId,
    'message': message,
    'attachment_url': attachmentUrl,
    'created_at': createdAt.toIso8601String(),
    'user': user?.toJson(),
  };
}
