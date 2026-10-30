import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({super.key, required this.category});

  Color _getColor() {
    switch (category) {
      case 'hardware':
        return AppColors.catHardware;
      case 'login':
        return AppColors.catLogin;
      case 'db_infra':
        return AppColors.catDbInfra;
      case 'financeiro':
        return AppColors.catFinanceiro;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.opacity12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        Formatters.formatCategory(category),
        style: AppTextStyles.badge.copyWith(
          color: color,
          fontSize: AppTextStyles.fontSize11,
        ),
      ),
    );
  }
}
