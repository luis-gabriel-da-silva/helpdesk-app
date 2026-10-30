import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';
import 'package:helpdesk_app/core/theme/app_spacing.dart';

class FileUploader extends StatelessWidget {
  final String? fileName;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const FileUploader({
    super.key,
    required this.fileName,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: CustomPaint(
        foregroundPainter: _DashedBorderPainter(
          color: AppColors.primary.withValues(alpha: AppColors.opacity40),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.space20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: AppColors.opacity035),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.attach_file,
                color: AppColors.primary,
                size: AppSpacing.space28,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                fileName ?? AppStrings.attachOrientative,
                textAlign: TextAlign.center,
                style: AppTextStyles.custom(
                  color: AppColors.textSecondary,
                  fontSize: AppTextStyles.fontSize13,
                ),
              ),
              if (fileName != null && onRemove != null)
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: AppSpacing.md),
                  label: const Text(AppStrings.removeFile),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final metric in borderPath.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 6).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + 4;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
