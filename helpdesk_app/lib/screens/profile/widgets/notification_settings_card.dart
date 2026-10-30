import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';

class NotificationSettingsCard extends StatelessWidget {
  final bool emailEnabled;
  final bool pushEnabled;
  final ValueChanged<bool> onEmailChanged;
  final ValueChanged<bool> onPushChanged;

  const NotificationSettingsCard({
    super.key,
    required this.emailEnabled,
    required this.pushEnabled,
    required this.onEmailChanged,
    required this.onPushChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: AppColors.opacity12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: AppColors.opacity14),
            blurRadius: AppSpacing.space20,
            offset: const Offset(AppSpacing.zero, AppSpacing.space6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.notificationSettings,
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(AppStrings.emailNotifications),
            subtitle: const Text(AppStrings.emailNotificationsDescription),
            value: emailEnabled,
            onChanged: onEmailChanged,
            activeTrackColor: AppColors.primary,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(AppStrings.appNotifications),
            subtitle: const Text(AppStrings.appNotificationsDescription),
            value: pushEnabled,
            onChanged: onPushChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
