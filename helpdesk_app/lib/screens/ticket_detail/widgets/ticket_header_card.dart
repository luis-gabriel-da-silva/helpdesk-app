import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/ticket_model.dart';
import '../../../../services/api_config.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';

class TicketHeaderCard extends StatelessWidget {
  final TicketModel ticket;

  const TicketHeaderCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: AppColors.opacity12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: AppColors.opacity12),
            blurRadius: AppSpacing.space18,
            offset: const Offset(AppSpacing.zero, AppSpacing.space5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space10,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: AppColors.opacity10,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: AppSpacing.space14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      Formatters.formatCategory(ticket.category),
                      style: AppTextStyles.custom(
                        fontSize: AppTextStyles.fontSize12,
                        fontWeight: AppTextStyles.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space10,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(ticket.status)
                      .withValues(alpha: AppColors.opacity15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  Formatters.formatStatus(ticket.status),
                  style: AppTextStyles.custom(
                    fontSize: AppTextStyles.fontSize12,
                    fontWeight: AppTextStyles.bold,
                    color: _getStatusColor(ticket.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          Text(
            ticket.title,
            style: AppTextStyles.custom(
              fontSize: AppTextStyles.fontSize18,
              fontWeight: AppTextStyles.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              CircleAvatar(
                radius: AppSpacing.avatarRadiusMedium,
                backgroundColor: AppColors.primary.withValues(
                  alpha: AppColors.opacity14,
                ),
                backgroundImage: ticket.user?.avatarUrl == null
                    ? null
                    : NetworkImage(
                        ApiConfig.resolveMediaUrl(ticket.user!.avatarUrl!),
                      ),
                child: ticket.user?.avatarUrl != null
                    ? null
                    : Text(
                        (ticket.user?.name.trim().isNotEmpty == true
                                ? ticket.user!.name.trim()[0]
                                : AppStrings.userInitial)
                            .toUpperCase(),
                        style: AppTextStyles.custom(
                          color: AppColors.primary,
                          fontWeight: AppTextStyles.bold,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.space10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.openedBy} ${ticket.user?.name ?? AppStrings.titleFallback}',
                      style: AppTextStyles.custom(
                        fontSize: AppTextStyles.fontSize13,
                        fontWeight: AppTextStyles.semiBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      Formatters.formatDate(ticket.createdAt),
                      style: AppTextStyles.custom(
                        fontSize: AppTextStyles.fontSize12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().replaceAll('_', ' ')) {
      case 'pendente':
        return AppColors.statusPendente;
      case 'em andamento':
        return AppColors.statusEmAndamento;
      case 'concluido':
      case 'concluído':
      case 'resolvido':
        return AppColors.priorityLow;
      default:
        return AppColors.primary;
    }
  }
}
