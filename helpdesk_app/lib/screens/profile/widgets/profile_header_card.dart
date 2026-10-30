import 'dart:typed_data';

import 'package:flutter/material.dart';

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
    final initial = name.trim().isEmpty ? 'U' : name.trim()[0].toUpperCase();

    return _ProfileCard(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary.withOpacity(0.14),
                backgroundImage: photoBytes == null
                    ? (photoUrl == null ? null : NetworkImage(photoUrl!))
                    : MemoryImage(photoBytes!),
                child: photoBytes == null && photoUrl == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
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
                    tooltip: 'Alterar foto',
                    onPressed: onChangePhoto,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
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
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: AppColors.primary, size: 19),
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
            'JPG, PNG ou WebP até 5MB',
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
