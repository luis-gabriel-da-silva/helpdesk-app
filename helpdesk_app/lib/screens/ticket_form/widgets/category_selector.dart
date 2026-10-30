import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  static const _options = [
    ('db_infra', 'Infra & DB', Icons.dns_outlined),
    ('login', 'Acesso & Login', Icons.lock_outline_rounded),
    ('financeiro', 'Financeiro', Icons.payments_outlined),
    ('hardware', 'Hardware', Icons.devices_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in _options)
          ChoiceChip(
            selected: selectedCategory == option.$1,
            onSelected: (_) => onChanged(option.$1),
            selectedColor: AppColors.primary.withOpacity(0.1),
            backgroundColor: AppColors.inputBackground,
            side: BorderSide(
              color: selectedCategory == option.$1
                  ? AppColors.primary.withOpacity(0.35)
                  : Colors.transparent,
            ),
            avatar: Icon(
              option.$3,
              size: 18,
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
