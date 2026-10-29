import 'package:flutter/material.dart';

abstract class AppColors {
  // Cores Principais (Base Violeta / Lavanda Pastel do Figma)
  static const Color primary = Color(0xFF5B3E96); // Roxo principal
  static const Color primaryLight = Color(0xFF7A59C2); // Roxo claro / hover
  static const Color background = Color(0xFFF3F0F9); // Fundo pastel lavanda
  static const Color surface = Color(0xFFFFFFFF); // Cards em branco puro
  static const Color inputBackground = Color(0xFFF8F6FC); // Fundo dos campos

  // Textos
  static const Color textPrimary = Color(0xFF2D2A32); // Grafite escuro
  static const Color textSecondary = Color(0xFF7A7585); // Cinza médio
  static const Color textLight = Color(0xFFA09CAB); // Placeholders

  // Badges de Status
  static const Color statusPendente = Color(0xFFD97706); // Laranja
  static const Color statusEmAndamento = Color(0xFF2563EB); // Azul
  static const Color statusConcluido = Color(0xFF16A34A); // Verde

  // Badges de Categorias
  static const Color catHardware = Color(0xFFDC2626); // Vermelho
  static const Color catLogin = Color(0xFF9333EA); // Roxo
  static const Color catDbInfra = Color(0xFFEA580C); // Laranja
  static const Color catFinanceiro = Color(0xFF0D9488); // Verde Água
}
