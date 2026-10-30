import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/ticket_message_model.dart';
import '../../../../services/api_config.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';
import 'package:helpdesk_app/core/theme/app_spacing.dart';

class TicketChatMessage extends StatelessWidget {
  final TicketMessageModel message;

  const TicketChatMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                message.user?.name ?? AppStrings.titleFallback,
                style: AppTextStyles.custom(
                  fontSize: AppTextStyles.fontSize13,
                  fontWeight: AppTextStyles.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                Formatters.formatDate(message.createdAt),
                style: AppTextStyles.custom(
                  fontSize: AppTextStyles.fontSize11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space6),
          Text(
            message.message,
            style: AppTextStyles.custom(
              fontSize: AppTextStyles.fontSize14,
              color: AppColors.textPrimary,
            ),
          ),
          if (message.attachmentUrl != null) ...[
            const SizedBox(height: AppSpacing.space10),
            _buildAttachment(message.attachmentUrl!),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachment(String rawUrl) {
    final url = ApiConfig.resolveMediaUrl(rawUrl);
    final uri = Uri.tryParse(url);
    final fileName = uri != null && uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : AppStrings.attachmentName;
    final extension = fileName.split('.').last.toLowerCase();
    final isImage = {'jpg', 'jpeg', 'png', 'webp'}.contains(extension);

    if (!isImage) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.attach_file,
            color: AppColors.primary,
            size: AppSpacing.space18,
          ),
          const SizedBox(height: AppSpacing.space6),
          Flexible(child: Text(fileName)),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Image.network(
        url,
        width: double.infinity,
        height: AppSpacing.attachmentPreviewHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          height: AppSpacing.space100,
          alignment: Alignment.center,
          color: AppColors.inputBackground,
          child: const Text(AppStrings.attachmentImageError),
        ),
      ),
    );
  }
}
