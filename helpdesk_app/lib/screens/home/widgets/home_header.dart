import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/user_model.dart';
import '../../../../widgets/helpdesk_logo.dart';
import '../../../../services/api_config.dart';
import '../../../core/constants/app_strings.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';
import 'package:helpdesk_app/core/theme/app_spacing.dart';

class HomeHeader extends StatelessWidget {
  final UserModel? user;
  final bool isTecnico;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;
  final int unreadCount;

  const HomeHeader({
    super.key,
    required this.user,
    required this.isTecnico,
    required this.onProfileTap,
    required this.onNotificationsTap,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final userName = user?.name.trim() ?? '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const HelpdeskLogo(),
            const SizedBox(width: AppSpacing.space12),
            Container(
              height: AppSpacing.space20,
              width: AppSpacing.hairline,
              color: AppColors.textSecondary.withValues(
                alpha: AppColors.opacity20,
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Text(
              AppStrings.portal,
              style: AppTextStyles.custom(
                fontSize: AppTextStyles.fontSize18,
                fontWeight: AppTextStyles.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: AppColors.opacity10),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                isTecnico ? AppStrings.technicianRole : AppStrings.customerRole,
                style: AppTextStyles.custom(
                  fontSize: AppTextStyles.fontSize10,
                  fontWeight: AppTextStyles.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              tooltip: AppStrings.notificationsTitle,
              onPressed: onNotificationsTap,
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
                backgroundColor: AppColors.dangerAccent,
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: AppSpacing.avatarRadiusSmall,
                backgroundColor: AppColors.primary.withValues(
                  alpha: AppColors.opacity15,
                ),
                backgroundImage: user?.avatarUrl == null
                    ? null
                    : NetworkImage(ApiConfig.resolveMediaUrl(user!.avatarUrl!)),
                child: user?.avatarUrl != null
                    ? null
                    : Text(
                        userName.isEmpty
                            ? AppStrings.userInitial
                            : userName[0].toUpperCase(),
                        style: AppTextStyles.custom(
                          fontWeight: AppTextStyles.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
