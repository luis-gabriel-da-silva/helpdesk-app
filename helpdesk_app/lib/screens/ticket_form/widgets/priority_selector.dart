import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String> onChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
  });

  static const _options = [
    ('baixa', 'Baixa', Colors.green),
    ('media', 'Média', Colors.amber),
    ('alta', 'Alta', Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final option in _options)
          ChoiceChip(
            selected: selectedPriority == option.$1,
            onSelected: (_) => onChanged(option.$1),
            selectedColor: Colors.white,
            backgroundColor: AppColors.inputBackground,
            side: BorderSide(
              color: selectedPriority == option.$1
                  ? AppColors.primary.withOpacity(0.35)
                  : Colors.transparent,
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: option.$3,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(option.$2),
              ],
            ),
          ),
      ],
    );
  }
}
