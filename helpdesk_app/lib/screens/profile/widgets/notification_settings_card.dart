import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class NotificationSettingsCard extends StatelessWidget {
  final bool emailEnabled;
  final bool pushEnabled;
  final ValueChanged<bool> onEmailChanged;
  final ValueChanged<bool> onPushChanged;

  const NotificationSettingsCard({
    super.key,
    required this.emailEnabled,
    required this.pushEnabled,
    required this.onEmailChanged,
    required this.onPushChanged,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Canais de Alerta', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Chamados por e-mail'),
            subtitle: const Text('Receba atualizações na sua caixa de entrada'),
            value: emailEnabled,
            onChanged: onEmailChanged,
            activeTrackColor: AppColors.primary,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Alertas no aplicativo'),
            subtitle: const Text('Avisos no painel enquanto o aplicativo estiver aberto'),
            value: pushEnabled,
            onChanged: onPushChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
