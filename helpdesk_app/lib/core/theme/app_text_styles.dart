import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  static const FontWeight normal = FontWeight.normal;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.bold;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  static const double logoLineHeight = 0.9;
  static const double logoLetterSpacing = 2.0;
  static const double fontSize9 = 9.0;
  static const double fontSize10 = 10.0;
  static const double fontSize11 = 11.0;
  static const double fontSize12 = 12.0;
  static const double fontSize13 = 13.0;
  static const double fontSize14 = 14.0;
  static const double fontSize15 = 15.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize22 = 22.0;
  static const double fontSize24 = 24.0;
  static const double fontSize34 = 34.0;

  // Títulos
  static const TextStyle titleLarge = TextStyle(
    fontSize: fontSize24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: fontSize18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: fontSize16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Corpo de texto (Body)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSize14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: fontSize12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Botões e Badges
  static const TextStyle button = TextStyle(
    fontSize: fontSize16,
    fontWeight: FontWeight.bold,
    color: AppColors.surface,
  );

  static const TextStyle badge = TextStyle(
    fontSize: fontSize12,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
  );

  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) => TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}
