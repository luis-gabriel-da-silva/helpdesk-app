import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';
import 'package:helpdesk_app/core/theme/app_spacing.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isTecnico;
  final ValueChanged<String> onChanged;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.isTecnico,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: AppColors.opacity14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: AppColors.opacity12),
            blurRadius: AppSpacing.md,
            offset: const Offset(AppSpacing.zero, AppSpacing.xs),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: isTecnico
              ? AppStrings.technicianSearch
              : AppStrings.customerSearch,
          hintStyle: AppTextStyles.custom(
            fontSize: AppTextStyles.fontSize13,
            color: AppColors.textSecondary.withValues(
              alpha: AppColors.opacity70,
            ),
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.space14,
          ),
        ),
      ),
    );
  }
}
