import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/status_badge.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TicketService _ticketService = TicketService();
  final AuthService _authService = AuthService();
  final _messageController = TextEditingController();

  TicketModel? _ticket;
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isSending = false;

  // Variáveis para anexo na resposta
  String? _filePath;
  Uint8List? _fileBytes;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _loadTicketDetails();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadTicketDetails() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getSavedUser();
      final ticket = await _ticketService.getTicketById(widget.ticketId);

      if (mounted) {
        setState(() {
          _currentUser = user;
          _ticket = ticket;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Ajustado para file_picker v13.0.0
  Future<void> _pickAttachment() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );

    if (files.isEmpty || !mounted) return;

    final file = files.first;
    final bytes = kIsWeb ? await file.readAsBytes() : null;
    if (!mounted) return;

    setState(() {
      _fileName = file.name;
      if (kIsWeb) {
        _fileBytes = bytes;
        _filePath = null;
      } else {
        _filePath = file.path;
        _fileBytes = null;
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _filePath == null && _fileBytes == null) return;

    setState(() => _isSending = true);

    try {
      await _ticketService.addMessage(
        widget.ticketId,
        text,
        filePath: _filePath,
        fileBytes: _fileBytes,
        fileName: _fileName,
      );

      _messageController.clear();
      setState(() {
        _filePath = null;
        _fileBytes = null;
        _fileName = null;
      });

      await _loadTicketDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await _ticketService.updateStatus(widget.ticketId, newStatus);
      await _loadTicketDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status do chamado atualizado!'),
            backgroundColor: AppColors.statusConcluido,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _ticket != null ? '#${_ticket!.id} - Detalhes' : 'Detalhes',
        ),
        actions: [
          if (_currentUser?.role == 'tecnico' && _ticket != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: _updateStatus,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'pendente',
                  child: Text('Marcar como Pendente'),
                ),
                PopupMenuItem(
                  value: 'em_andamento',
                  child: Text('Marcar como Em Andamento'),
                ),
                PopupMenuItem(
                  value: 'concluido',
                  child: Text('Marcar como Concluído'),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 750,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _ticket == null
              ? const Center(child: Text('Chamado não encontrado.'))
              : Column(
                  children: [
                    // Cabeçalho do Chamado
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      color: AppColors.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CategoryBadge(category: _ticket!.category),
                              StatusBadge(status: _ticket!.status),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _ticket!.title,
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Aberto em ${Formatters.formatDate(_ticket!.createdAt)} por ${_ticket!.user?.name ?? "Usuário"}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Lista de Mensagens / Respostas
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _ticket!.messages.length,
                        itemBuilder: (context, index) {
                          final msg = _ticket!.messages[index];
                          final isMe = msg.user?.id == _currentUser?.id;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.user?.name ?? 'Usuário',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isMe
                                          ? Colors.white70
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    msg.message,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isMe
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (msg.attachmentUrl != null) ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    InkWell(
                                      onTap: () {},
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.attachment_rounded,
                                            size: 16,
                                            color: isMe
                                                ? Colors.white
                                                : AppColors.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Ver Anexo',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isMe
                                                  ? Colors.white
                                                  : AppColors.primary,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.xs),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      Formatters.formatDate(msg.createdAt),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe
                                            ? Colors.white60
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Barra de Envio de Resposta
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      color: AppColors.surface,
                      child: Column(
                        children: [
                          if (_fileName != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.xs,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.attach_file,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _fileName!,
                                      style: AppTextStyles.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () {
                                      setState(() {
                                        _fileName = null;
                                        _filePath = null;
                                        _fileBytes = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.attach_file_rounded),
                                onPressed: _pickAttachment,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    hintText: 'Escreva uma resposta...',
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: _isSending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send_rounded,
                                        color: AppColors.primary,
                                      ),
                                onPressed: _isSending ? null : _sendMessage,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
