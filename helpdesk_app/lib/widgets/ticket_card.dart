import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../models/ticket_model.dart';
import 'category_badge.dart';
import 'status_badge.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool highlightAsNew;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.onDelete,
    this.highlightAsNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: highlightAsNew ? 5 : 3,
      shadowColor: (highlightAsNew ? const Color(0xFFE44B5D) : const Color(0xFF5B3E96)).withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: highlightAsNew ? const Color(0xFFE44B5D).withOpacity(0.55) : const Color(0xFF5B3E96).withOpacity(0.16)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CategoryBadge(category: ticket.category),
                      if (highlightAsNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFFECEE), borderRadius: BorderRadius.circular(20)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.priority_high_rounded, size: 15, color: Color(0xFFD93045)),
                            SizedBox(width: 3),
                            Text('NOVO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD93045))),
                          ]),
                        ),
                      ],
                    ],
                  ),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    StatusBadge(status: ticket.status),
                    if (onDelete != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Apagar chamado',
                        visualDensity: VisualDensity.compact,
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD93045), size: 21),
                      ),
                    ],
                  ]),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ticket.title,
                style: AppTextStyles.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aberto por: ${ticket.user?.name ?? "Usuário"}',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    Formatters.formatDate(ticket.createdAt),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
