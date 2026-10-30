import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../models/user_model.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';

class HomeWelcomeCard extends StatelessWidget {
  final UserModel? user;
  final bool isTecnico;
  final int totalTickets;

  const HomeWelcomeCard({
    super.key,
    required this.user,
    required this.isTecnico,
    required this.totalTickets,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = user?.name.trim().split(' ').first;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        gradient: const LinearGradient(
          colors: [AppColors.surface, AppColors.surfaceTint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: AppColors.opacity18),
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
            children: [
              Flexible(
                child: Text(
                  '${AppStrings.greeting}, ${firstName == null || firstName.isEmpty ? AppStrings.unknownUser : firstName}',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.custom(
                    fontSize: AppTextStyles.fontSize20,
                    fontWeight: AppTextStyles.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (!isTecnico) ...[
                const SizedBox(width: AppSpacing.space6),
                const Icon(Icons.waving_hand_rounded, color: AppColors.primary),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isTecnico
                ? '$totalTickets ${AppStrings.technicianWelcome}'
                : AppStrings.customerWelcome,
            style: AppTextStyles.custom(
              fontSize: AppTextStyles.fontSize12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
