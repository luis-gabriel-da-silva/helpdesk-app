import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static const RadialGradient cloudyBackgroundGradient = RadialGradient(
    center: Alignment(0.0, -0.4),
    radius: 1.4,
    colors: [
      AppColors.surface,
      AppColors.backgroundGradientMid,
      AppColors.backgroundGradientEnd,
    ],
    stops: [0.2, 0.65, 1.0],
  );

  static const RadialGradient loginBackgroundGradient = RadialGradient(
    center: Alignment(0.0, -0.2),
    radius: 1.3,
    colors: [
      AppColors.surface,
      AppColors.loginGradientMid,
      AppColors.loginGradientEnd,
    ],
    stops: [0.2, 0.65, 1.0],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: AppSpacing.zero,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTextStyles.titleMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppSpacing.focusedBorderWidth,
          ),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          minimumSize: const Size.fromHeight(AppSpacing.space52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppSpacing.hairline,
        shadowColor: AppColors.primary.withValues(alpha: AppColors.opacity08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
    );
  }
}
