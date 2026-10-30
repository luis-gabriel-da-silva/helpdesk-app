import 'package:flutter/material.dart';

abstract class AppColors {
  // Opacidades para estados, fundos e bordas translúcidos.
  static const double opacity035 = 0.035;
  static const double opacity08 = 0.08;
  static const double opacity10 = 0.1;
  static const double opacity12 = 0.12;
  static const double opacity14 = 0.14;
  static const double opacity15 = 0.15;
  static const double opacity16 = 0.16;
  static const double opacity18 = 0.18;
  static const double opacity20 = 0.2;
  static const double opacity35 = 0.35;
  static const double opacity40 = 0.4;
  static const double opacity55 = 0.55;
  static const double opacity60 = 0.6;
  static const double opacity70 = 0.7;

  // Cores Principais (Base Violeta / Lavanda Pastel do Figma)
  static const Color primary = Color(0xFF5B3E96); // Roxo principal
  static const Color background = Color(0xFFF3F0F9); // Fundo pastel lavanda
  static const Color surface = Color(0xFFFFFFFF); // Cards em branco puro
  static const Color inputBackground = Color(0xFFF8F6FC); // Fundo dos campos
  static const Color surfaceTint = Color(0xFFF8F5FF);
  static const Color surfaceMuted = Color(0xFFF0ECF7);
  static const Color transparent = Color(0x00000000);
  static const Color border = Color(0xFFE2E8F0);

  // Fundos decorativos
  static const Color backgroundGradientMid = Color(0xFFF6F2FC);
  static const Color backgroundGradientEnd = Color(0xFFEDE6F8);
  static const Color loginGradientMid = Color(0xFFF3EEFB);
  static const Color loginGradientEnd = Color(0xFFE8DEF8);

  // Textos
  static const Color textPrimary = Color(0xFF2D2A32); // Grafite escuro
  static const Color textSecondary = Color(0xFF7A7585); // Cinza médio
  static const Color textLight = Color(0xFFA09CAB); // Placeholders

  // Badges de Status
  static const Color statusPendente = Color(0xFFD97706); // Laranja
  static const Color statusEmAndamento = Color(0xFF2563EB); // Azul
  static const Color statusConcluido = Color(0xFF16A34A); // Verde
  static const Color danger = Color(0xFFD93045);
  static const Color dangerAccent = Color(0xFFE44B5D);
  static const Color dangerSurface = Color(0xFFFFECEE);
  static const Color dangerBorder = Color(0xFFE7A0A7);
  static const Color priorityLow = Color(0xFF16A34A);
  static const Color priorityMedium = Color(0xFFFFC107);
  static const Color priorityHigh = Color(0xFFF44336);

  // Badges de Categorias
  static const Color catHardware = Color(0xFFDC2626); // Vermelho
  static const Color catLogin = Color(0xFF9333EA); // Roxo
  static const Color catDbInfra = Color(0xFFEA580C); // Laranja
  static const Color catFinanceiro = Color(0xFF0D9488); // Verde Água
}
