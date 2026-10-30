import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';
import 'package:helpdesk_app/core/theme/app_spacing.dart';

class HomeFilterChips extends StatelessWidget {
  final String selectedFilter;
  final bool isTecnico;
  final ValueChanged<String> onFilterSelected;

  const HomeFilterChips({
    super.key,
    required this.selectedFilter,
    required this.isTecnico,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = isTecnico
        ? AppStrings.technicianFilters
        : AppStrings.customerFilters;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) {
                if (val) onFilterSelected(filter);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: AppTextStyles.custom(
                color: isSelected ? AppColors.surface : AppColors.textSecondary,
                fontWeight: isSelected
                    ? AppTextStyles.bold
                    : AppTextStyles.normal,
                fontSize: AppTextStyles.fontSize12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
