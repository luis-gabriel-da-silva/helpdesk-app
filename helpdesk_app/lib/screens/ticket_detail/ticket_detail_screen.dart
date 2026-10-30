import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ticket_message_model.dart';
import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/helpdesk_logo.dart';
import '../../widgets/responsive_container.dart';
import 'widgets/ticket_chat_message.dart';
import 'widgets/ticket_header_card.dart';
import 'widgets/ticket_status_actions.dart';
import '../../core/constants/app_strings.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';

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
  String? _loadError;
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
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
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
      if (mounted) {
        setState(() {
          _loadError = AppStrings.loadTicketError;
          _isLoading = false;
        });
      }
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
      padding: EdgeInsets.only(right: AppSpacing.md),
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
        const SnackBar(content: Text(AppStrings.updateStatusError)),
      );
    }
  }

  Future<void> _editTicket() async {
    final ticket = _ticket;
    if (ticket == null) return;
    final updated = await context.pushNamed<bool>(
      AppRoutes.ticketEdit,
      pathParameters: {'id': ticket.id.toString()},
    );
    if (mounted && updated == true) await _loadTicketDetails();
  }

  Future<void> _confirmDelete() async {
    final ticket = _ticket;
    if (ticket == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.deleteTicketTitle),
        content: Text(AppStrings.ticketDeleteConfirmation(ticket.id)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(AppStrings.delete),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.sendMessageError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: AppStrings.goBack,
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
            tooltip: AppStrings.goBack,
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(AppStrings.ticketDetails),
          actions: _logoActions(),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError ?? AppStrings.ticketNotFound),
              TextButton(
                onPressed: _loadTicketDetails,
                child: Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppStrings.goBack,
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(AppStrings.ticketDetailTitle(_ticket!.id)),
        actions: _logoActions(),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: AppSpacing.zero,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.cloudyBackgroundGradient,
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ResponsiveContainer(
              maxWidth: AppSpacing.maxWidthDetails,
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
                          if (!_isTecnico &&
                              _ticket!.user?.id == _currentUserId &&
                              _ticket!.status.toLowerCase() != 'concluido') ...[
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: _editTicket,
                                icon: const Icon(Icons.edit_outlined),
                                label: Text(AppStrings.editTicketAction),
                              ),
                            ),
                          ],
                          if (_isTecnico ||
                              _ticket!.user?.id == _currentUserId) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: _isDeleting ? null : _confirmDelete,
                                icon: const Icon(Icons.delete_outline_rounded),
                                label: Text(
                                  _isDeleting
                                      ? AppStrings.deleting
                                      : AppStrings.deleteTicketAction,
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  side: const BorderSide(
                                    color: AppColors.dangerBorder,
                                  ),
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
                          Text(
                            AppStrings.interactionsHistory,
                            style: AppTextStyles.custom(
                              fontSize: AppTextStyles.fontSize14,
                              fontWeight: AppTextStyles.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (_messages.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.lg,
                              ),
                              child: Center(
                                child: Text(
                                  AppStrings.noReplies,
                                  style: AppTextStyles.custom(
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
                              separatorBuilder: (_, _) =>
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
                      color: AppColors.surface,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.primary.withValues(
                            alpha: AppColors.opacity14,
                          ),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: AppColors.opacity14,
                          ),
                          blurRadius: AppSpacing.md,
                          offset: const Offset(AppSpacing.zero, -4),
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
                              hintText: AppStrings.replyHint,
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
