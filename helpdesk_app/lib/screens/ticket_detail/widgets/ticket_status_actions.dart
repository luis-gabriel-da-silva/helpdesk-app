import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alterar Status do Chamado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatusButton(
                label: 'Pendente',
                statusKey: 'pendente',
                currentStatus: currentStatus,
                color: Colors.orange,
                onTap: () => onStatusChanged('pendente'),
              ),
              const SizedBox(width: 8),
              _StatusButton(
                label: 'Em Andamento',
                statusKey: 'em_andamento',
                currentStatus: currentStatus,
                color: Colors.blue,
                onTap: () => onStatusChanged('em_andamento'),
              ),
              const SizedBox(width: 8),
              _StatusButton(
                label: 'Concluído',
                statusKey: 'concluido',
                currentStatus: currentStatus,
                color: Colors.green,
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.transparent),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
