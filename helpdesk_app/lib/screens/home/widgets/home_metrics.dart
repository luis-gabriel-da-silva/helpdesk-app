import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../models/ticket_model.dart';

class HomeMetrics extends StatelessWidget {
  final List<TicketModel> tickets;
  final bool isTecnico;

  const HomeMetrics({
    super.key,
    required this.tickets,
    required this.isTecnico,
  });

  @override
  Widget build(BuildContext context) {
    final pending = tickets
        .where((t) => t.status.toLowerCase() == 'pendente')
        .length;
    final progress = tickets
        .where((t) => t.status.toLowerCase().replaceAll('_', ' ') == 'em andamento')
        .length;
    final done = tickets
        .where((t) => t.status.toLowerCase().replaceAll('_', '').startsWith('conclu'))
        .length;

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: isTecnico ? 'Pendentes' : 'Abertos',
            value: pending.toString(),
            subtitle: isTecnico ? '' : 'Aguardando',
            icon: Icons.hourglass_empty_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _MetricCard(
            title: isTecnico ? 'Andamento' : 'Em Ação',
            value: progress.toString(),
            subtitle: isTecnico ? '' : 'Em análise',
            icon: Icons.sync_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _MetricCard(
            title: isTecnico ? 'Concluído' : 'Finalizados',
            value: done.toString(),
            subtitle: isTecnico ? '' : 'Este mês',
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 16, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
