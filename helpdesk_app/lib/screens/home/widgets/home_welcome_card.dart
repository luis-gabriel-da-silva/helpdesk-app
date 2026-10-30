import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../models/user_model.dart';

class HomeWelcomeCard extends StatelessWidget {
  final UserModel? user;
  final bool isTecnico;
  final int totalTickets;

  const HomeWelcomeCard({
    super.key,
    required this.user,
    required this.isTecnico,
    required this.totalTickets,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = user?.name.trim().split(' ').first;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8F5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'Olá, ${firstName == null || firstName.isEmpty ? 'Usuário' : firstName}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (!isTecnico) ...[
                const SizedBox(width: 6),
                const Text('👋'),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isTecnico
                ? '⚡ $totalTickets chamados sob seu monitoramento hoje'
                : 'Acompanhe o andamento das suas solicitações em tempo real',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
