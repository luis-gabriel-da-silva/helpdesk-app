class AppNotificationModel {
  final int id;
  final int? ticketId;
  final String title;
  final String body;
  final String ticketTitle;
  final String type;
  final String? ticketCategory;
  final String? openedBy;
  final String? senderName;
  final bool isRead;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    required this.ticketId,
    required this.title,
    required this.body,
    required this.ticketTitle,
    required this.type,
    required this.ticketCategory,
    required this.openedBy,
    required this.senderName,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      AppNotificationModel(
        id: json['id'] as int,
        ticketId: json['ticket_id'] as int?,
        title: json['title'] as String? ?? 'Notificação',
        body: json['body'] as String? ?? '',
        ticketTitle: json['ticket_title'] as String? ?? '',
        type: json['type'] as String? ?? '',
        ticketCategory: json['ticket_category'] as String?,
        openedBy: json['opened_by'] as String?,
        senderName: json['sender_name'] as String?,
        isRead: json['read_at'] != null || json['is_read'] == true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'ticket_id': ticketId,
    'title': title,
    'body': body,
    'ticket_title': ticketTitle,
    'type': type,
    'ticket_category': ticketCategory,
    'opened_by': openedBy,
    'sender_name': senderName,
    'is_read': isRead,
    'created_at': createdAt.toIso8601String(),
  };
}
