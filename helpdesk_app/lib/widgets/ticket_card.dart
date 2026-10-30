import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../models/ticket_model.dart';
import 'category_badge.dart';
import 'status_badge.dart';
import '../core/constants/app_strings.dart';

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
      shadowColor: (highlightAsNew ? AppColors.dangerAccent : AppColors.primary)
          .withValues(alpha: AppColors.opacity20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(
          color: highlightAsNew
              ? AppColors.dangerAccent.withValues(alpha: AppColors.opacity55)
              : AppColors.primary.withValues(alpha: AppColors.opacity16),
        ),
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
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.dangerSurface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXl,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.priority_high_rounded,
                                size: AppSpacing.space15,
                                color: AppColors.danger,
                              ),
                              SizedBox(width: AppSpacing.space3),
                              Text(
                                AppStrings.newBadge,
                                style: AppTextStyles.custom(
                                  fontSize: AppTextStyles.fontSize10,
                                  fontWeight: AppTextStyles.bold,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(status: ticket.status),
                      if (onDelete != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        IconButton(
                          tooltip: AppStrings.deleteTicketAction,
                          visualDensity: VisualDensity.compact,
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.danger,
                            size: AppSpacing.space21,
                          ),
                        ),
                      ],
                    ],
                  ),
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
                    '${AppStrings.openedBy}: ${ticket.user?.name ?? AppStrings.titleFallback}',
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
