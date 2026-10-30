import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/ticket_message_model.dart';
import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/helpdesk_logo.dart';
import '../../widgets/responsive_container.dart';
import 'widgets/ticket_chat_message.dart';
import 'widgets/ticket_header_card.dart';
import 'widgets/ticket_status_actions.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _ticketService = TicketService();
  final _authService = AuthService();
  final _messageController = TextEditingController();

  TicketModel? _ticket;
  List<TicketMessageModel> _messages = [];
  bool _isLoading = true;
  bool _isTecnico = false;
  bool _isDeleting = false;
  int? _currentUserId;

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
      final id = int.parse(widget.ticketId);
      final ticket = await _ticketService.getTicketById(id);

      if (!mounted) return;
      setState(() {
        _ticket = ticket;
        _messages = ticket.messages;
        _isTecnico = user?.role.toLowerCase() == 'tecnico';
        _currentUserId = user?.id;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.home);
    }
  }

  List<Widget> _logoActions() => const [
    Padding(
      padding: EdgeInsets.only(right: 16),
      child: HelpdeskLogo(scale: 0.85),
    ),
  ];

  Future<void> _updateStatus(String newStatus) async {
    if (_ticket == null) return;
    try {
      final updatedTicket = await _ticketService.updateStatus(
        _ticket!.id,
        newStatus,
      );
      if (!mounted) return;
      setState(() {
        _ticket = updatedTicket;
        _messages = updatedTicket.messages;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar status do chamado.')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final ticket = _ticket;
    if (ticket == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apagar chamado?'),
        content: Text(
          'O chamado #${ticket.id} e todo o historico serao apagados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await _ticketService.deleteTicket(ticket.id);
      if (!mounted) return;
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.goNamed(AppRoutes.home);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _ticket == null) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      await _ticketService.addMessage(_ticket!.id, content);
      if (mounted) await _loadTicketDetails();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao enviar mensagem.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Voltar',
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back),
          ),
          actions: _logoActions(),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_ticket == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Voltar',
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Detalhes do Chamado'),
          actions: _logoActions(),
        ),
        body: const Center(child: Text('Chamado não encontrado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('#${_ticket!.id} - Detalhes'),
        actions: _logoActions(),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.4),
            radius: 1.4,
            colors: [Color(0xFFFFFFFF), Color(0xFFF6F2FC), Color(0xFFEDE6F8)],
            stops: [0.2, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ResponsiveContainer(
              maxWidth: 1000,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TicketHeaderCard(ticket: _ticket!),
                          if (_isTecnico || _ticket!.user?.id == _currentUserId) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: _isDeleting ? null : _confirmDelete,
                                icon: const Icon(Icons.delete_outline_rounded),
                                label: Text(_isDeleting ? 'Apagando...' : 'Apagar chamado'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFD93045),
                                  side: const BorderSide(color: Color(0xFFE7A0A7)),
                                ),
                              ),
                            ),
                          ],
                          if (_isTecnico) ...[
                            const SizedBox(height: AppSpacing.md),
                            TicketStatusActions(
                              currentStatus: _ticket!.status,
                              onStatusChanged: _updateStatus,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          const Text(
                            'Histórico de Interações',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (_messages.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'Nenhuma resposta cadastrada ainda.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _messages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                return TicketChatMessage(
                                  message: _messages[index],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Barra Inferior de Envio de Mensagem
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.primary.withOpacity(0.14),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.14),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.attach_file_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {},
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Escreva uma resposta...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                            color: AppColors.primary,
                          ),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
