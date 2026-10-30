import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/user_model.dart';
import '../../../../widgets/helpdesk_logo.dart';
import '../../../../services/api_config.dart';

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
            const SizedBox(width: 12),
            Container(
              height: 20,
              width: 1,
              color: AppColors.textSecondary.withOpacity(0.2),
            ),
            const SizedBox(width: 12),
            Text(
              'Portal',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isTecnico ? 'TÉCNICO' : 'CLIENTE',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              tooltip: 'Notificações',
              onPressed: onNotificationsTap,
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
                backgroundColor: const Color(0xFFE44B5D),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onProfileTap,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.15),
              backgroundImage: user?.avatarUrl == null
                  ? null
                  : NetworkImage(ApiConfig.resolveMediaUrl(user!.avatarUrl!)),
              child: user?.avatarUrl != null
                  ? null
                  : Text(
                      userName.isEmpty ? 'U' : userName[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
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
