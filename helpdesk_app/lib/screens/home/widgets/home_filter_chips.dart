import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
        ? ['Todos', 'Pendentes', 'Em Andamento', 'Concluídos']
        : ['Todos', 'Abertos', 'Em Ação', 'Resolvidos'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) {
                if (val) onFilterSelected(filter);
              },
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
