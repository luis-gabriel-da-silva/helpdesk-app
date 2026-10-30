import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';
import 'package:helpdesk_app/core/theme/app_spacing.dart';

class TicketStatusActions extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onStatusChanged;

  const TicketStatusActions({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: AppColors.opacity12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: AppColors.opacity12),
            blurRadius: AppSpacing.md,
            offset: const Offset(AppSpacing.zero, AppSpacing.xs),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.newStatusTitle,
            style: AppTextStyles.custom(
              fontSize: AppTextStyles.fontSize12,
              fontWeight: AppTextStyles.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _StatusButton(
                label: AppStrings.statusPending,
                statusKey: 'pendente',
                currentStatus: currentStatus,
                color: AppColors.statusPendente,
                onTap: () => onStatusChanged('pendente'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatusButton(
                label: AppStrings.statusInProgress,
                statusKey: 'em_andamento',
                currentStatus: currentStatus,
                color: AppColors.statusEmAndamento,
                onTap: () => onStatusChanged('em_andamento'),
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatusButton(
                label: AppStrings.statusCompleted,
                statusKey: 'concluido',
                currentStatus: currentStatus,
                color: AppColors.priorityLow,
                onTap: () => onStatusChanged('concluido'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final String statusKey;
  final String currentStatus;
  final Color color;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.statusKey,
    required this.currentStatus,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        currentStatus.toLowerCase().replaceAll(' ', '_') == statusKey;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space10),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : color.withValues(alpha: AppColors.opacity10),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? color : AppColors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.custom(
                fontSize: AppTextStyles.fontSize12,
                fontWeight: AppTextStyles.bold,
                color: isSelected ? AppColors.surface : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
