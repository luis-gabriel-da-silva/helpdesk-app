import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/ticket_message_model.dart';
import '../../../../services/api_config.dart';

class TicketChatMessage extends StatelessWidget {
  final TicketMessageModel message;

  const TicketChatMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                message.user?.name ?? 'Usuário',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                Formatters.formatDate(message.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message.message,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          if (message.attachmentUrl != null) ...[
            const SizedBox(height: 10),
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
        : 'Anexo';
    final extension = fileName.split('.').last.toLowerCase();
    final isImage = {'jpg', 'jpeg', 'png', 'webp'}.contains(extension);

    if (!isImage) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Flexible(child: Text(fileName)),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: double.infinity,
        height: 240,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 100,
          alignment: Alignment.center,
          color: AppColors.inputBackground,
          child: const Text('Não foi possível carregar a imagem do anexo.'),
        ),
      ),
    );
  }
}
