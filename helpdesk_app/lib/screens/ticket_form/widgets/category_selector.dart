import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';

import 'package:helpdesk_app/core/theme/app_spacing.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  static const _options = [
    ('db_infra', AppStrings.catInfraSelector, Icons.dns_outlined),
    ('login', AppStrings.catLoginSelector, Icons.lock_outline_rounded),
    ('financeiro', AppStrings.catFinanceiro, Icons.payments_outlined),
    ('hardware', AppStrings.catHardware, Icons.devices_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in _options)
          ChoiceChip(
            selected: selectedCategory == option.$1,
            onSelected: (_) => onChanged(option.$1),
            selectedColor: AppColors.primary.withValues(
              alpha: AppColors.opacity10,
            ),
            backgroundColor: AppColors.inputBackground,
            side: BorderSide(
              color: selectedCategory == option.$1
                  ? AppColors.primary.withValues(alpha: AppColors.opacity35)
                  : AppColors.transparent,
            ),
            avatar: Icon(
              option.$3,
              size: AppSpacing.space18,
              color: selectedCategory == option.$1
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            label: Text(option.$2),
          ),
      ],
    );
  }
}
