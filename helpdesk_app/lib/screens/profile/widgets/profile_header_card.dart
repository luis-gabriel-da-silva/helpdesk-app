import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String position;
  final String employeeCode;
  final Uint8List? photoBytes;
  final String? photoUrl;
  final VoidCallback onChangePhoto;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.position,
    required this.employeeCode,
    required this.photoBytes,
    this.photoUrl,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? AppStrings.userInitial
        : name.trim()[0].toUpperCase();

    return _ProfileCard(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: AppSpacing.avatarRadiusLarge,
                backgroundColor: AppColors.primary.withValues(
                  alpha: AppColors.opacity14,
                ),
                backgroundImage: photoBytes == null
                    ? (photoUrl == null ? null : NetworkImage(photoUrl!))
                    : MemoryImage(photoBytes!),
                child: photoBytes == null && photoUrl == null
                    ? Text(
                        initial,
                        style: AppTextStyles.custom(
                          color: AppColors.primary,
                          fontSize: AppTextStyles.fontSize34,
                          fontWeight: AppTextStyles.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: AppStrings.changePhoto,
                    onPressed: onChangePhoto,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: AppColors.surface,
                      size: AppSpacing.space18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge,
                ),
              ),
              const SizedBox(width: AppSpacing.space6),
              const Icon(
                Icons.verified,
                color: AppColors.primary,
                size: AppSpacing.space19,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$position  •  $employeeCode',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            AppStrings.profileImageFormats,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Widget child;

  const _ProfileCard({required this.child});

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
      child: child,
    );
  }
}
