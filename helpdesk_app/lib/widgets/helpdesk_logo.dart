import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class HelpdeskLogo extends StatelessWidget {
  final double scale;

  const HelpdeskLogo({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'HELP!\n',
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              height: 0.9,
            ),
          ),
          TextSpan(
            text: 'DESK',
            style: TextStyle(
              fontSize: 9 * scale,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 2 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
