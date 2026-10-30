import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';

class HelpdeskLogo extends StatelessWidget {
  final double scale;

  const HelpdeskLogo({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: AppStrings.logoHelp,
            style: AppTextStyles.custom(
              fontSize: AppTextStyles.fontSize18 * scale,
              fontWeight: AppTextStyles.black,
              color: AppColors.primary,
              height: AppTextStyles.logoLineHeight,
            ),
          ),
          TextSpan(
            text: AppStrings.logoDesk,
            style: AppTextStyles.custom(
              fontSize: AppTextStyles.fontSize9 * scale,
              fontWeight: AppTextStyles.extraBold,
              color: AppColors.textPrimary,
              letterSpacing: AppTextStyles.logoLetterSpacing * scale,
            ),
          ),
        ],
      ),
    );
  }
}
