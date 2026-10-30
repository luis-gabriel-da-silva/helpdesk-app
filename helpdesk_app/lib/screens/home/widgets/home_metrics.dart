import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../models/ticket_model.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';

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
        .where(
          (t) => t.status.toLowerCase().replaceAll('_', ' ') == 'em andamento',
        )
        .length;
    final done = tickets
        .where(
          (t) =>
              t.status.toLowerCase().replaceAll('_', '').startsWith('conclu'),
        )
        .length;

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: isTecnico ? AppStrings.filterPending : AppStrings.filterOpen,
            value: pending.toString(),
            subtitle: isTecnico ? '' : AppStrings.waiting,
            icon: Icons.hourglass_empty_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _MetricCard(
            title: isTecnico
                ? AppStrings.metricInProgress
                : AppStrings.filterInAction,
            value: progress.toString(),
            subtitle: isTecnico ? '' : AppStrings.underReview,
            icon: Icons.sync_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _MetricCard(
            title: isTecnico
                ? AppStrings.statusCompleted
                : AppStrings.metricFinished,
            value: done.toString(),
            subtitle: isTecnico ? '' : AppStrings.thisMonth,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: AppColors.opacity12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: AppColors.opacity12),
            blurRadius: AppSpacing.md,
            offset: const Offset(AppSpacing.zero, AppSpacing.xs),
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
                style: AppTextStyles.custom(
                  fontSize: AppTextStyles.fontSize11,
                  color: AppColors.textSecondary,
                  fontWeight: AppTextStyles.medium,
                ),
              ),
              Icon(icon, size: AppSpacing.md, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.space6),
          Text(
            value,
            style: AppTextStyles.custom(
              fontSize: AppTextStyles.fontSize22,
              fontWeight: AppTextStyles.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space2),
            Text(
              subtitle,
              style: AppTextStyles.custom(
                fontSize: AppTextStyles.fontSize10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
