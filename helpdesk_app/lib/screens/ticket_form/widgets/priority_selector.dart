import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

import 'package:helpdesk_app/core/theme/app_spacing.dart';

class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
  });

  static const _options = [
    ('baixa', AppStrings.priorityLow, AppColors.priorityLow),
    ('media', AppStrings.priorityMedium, AppColors.priorityMedium),
    ('alta', AppStrings.priorityHigh, AppColors.priorityHigh),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.space10,
      runSpacing: AppSpacing.space10,
      children: [
        for (final option in _options)
          ChoiceChip(
            selected: selectedPriority == option.$1,
            onSelected: (_) => onChanged(option.$1),
            selectedColor: AppColors.surface,
            backgroundColor: AppColors.inputBackground,
            side: BorderSide(
              color: selectedPriority == option.$1
                  ? AppColors.primary.withValues(alpha: AppColors.opacity35)
                  : AppColors.transparent,
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSpacing.space9,
                  height: AppSpacing.space9,
                  decoration: BoxDecoration(
                    color: option.$3,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(option.$2),
              ],
            ),
          ),
      ],
    );
  }
}
