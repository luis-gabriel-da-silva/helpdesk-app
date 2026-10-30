import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../models/app_notification_model.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/ticket_card.dart';
import 'widgets/home_filter_chips.dart';
import 'widgets/home_header.dart';
import 'widgets/home_metrics.dart';
import 'widgets/home_welcome_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _ticketService = TicketService();
  final _notificationService = NotificationService();
  final _searchController = TextEditingController();

  UserModel? _user;
  List<TicketModel> _tickets = [];
  List<AppNotificationModel> _notifications = [];
  int _unreadCount = 0;
  Timer? _refreshTimer;
  bool _isLoading = true;
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _loadData(showLoading: false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    try {
      final user = await _authService.getSavedUser();
      final results = await Future.wait([
        _ticketService.getTickets(),
        _notificationService.getNotifications(),
      ]);
      final tickets = results[0] as List<TicketModel>;
      final notifications = results[1] as NotificationSnapshot;

      if (!mounted) return;
      setState(() {
        _user = user;
        _tickets = tickets;
        _notifications = notifications.notifications;
        _unreadCount = notifications.unreadCount;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted && showLoading) setState(() => _isLoading = false);
    }
  }

  Future<void> _openProfile() async {
    final currentUser = _user;
    if (currentUser == null) return;
    final updatedUser = await context.pushNamed<UserModel>(
      AppRoutes.profile,
      pathParameters: {'id': currentUser.id.toString()},
    );
    if (!mounted || updatedUser == null) return;
    setState(() => _user = updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado.')),
    );
  }

  Future<void> _openTicketForm() async {
    final created = await context.pushNamed<bool>(AppRoutes.ticketForm);
    if (mounted && created == true) await _loadData();
  }

  Future<void> _openTicketDetails(TicketModel ticket) async {
    final deleted = await context.pushNamed<bool>(
      AppRoutes.ticketDetail,
      pathParameters: {'id': ticket.id.toString()},
    );
    if (!mounted) return;
    await _loadData();
    if (mounted && deleted == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chamado apagado.')),
      );
    }
  }

  Future<void> _showNotifications() async {
    try {
      final snapshot = await _notificationService.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = snapshot.notifications;
        _unreadCount = snapshot.unreadCount;
      });
    } catch (_) {}
    if (!mounted) return;
    final selected = await showDialog<AppNotificationModel>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(children: [
          const Expanded(child: Text('Notificações')),
          if (_unreadCount > 0)
            Text('$_unreadCount novas', style: const TextStyle(fontSize: 12, color: Color(0xFFE44B5D))),
        ]),
        content: SizedBox(
          width: 460,
          height: 420,
          child: _notifications.isEmpty
              ? const Center(child: Text('Você está em dia. Nenhuma notificação por aqui.'))
              : ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      leading: CircleAvatar(
                        backgroundColor: notification.isRead ? const Color(0xFFF0ECF7) : const Color(0xFFFFECEE),
                        child: Icon(
                          notification.title.toLowerCase().contains('mensagem') ? Icons.chat_bubble_outline_rounded : Icons.confirmation_number_outlined,
                          color: notification.isRead ? AppColors.primary : const Color(0xFFD93045),
                        ),
                      ),
                      title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold)),
                      subtitle: Text(
                        '${notification.ticketTitle}\n${_notificationDetails(notification)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      onTap: () => Navigator.of(dialogContext).pop(notification),
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Fechar'))],
      ),
    );
    if (selected == null) return;
    try {
      await _notificationService.markRead(selected.id);
    } catch (_) {}
    await _loadData(showLoading: false);
    if (mounted && selected.ticketId != null) {
      final matches = _tickets.where((item) => item.id == selected.ticketId);
      final ticket = matches.isEmpty ? null : matches.first;
      if (ticket != null) await _openTicketDetails(ticket);
    }
  }

  String _notificationDetails(AppNotificationModel notification) {
    final category = notification.ticketCategory == null
        ? null
        : Formatters.formatCategory(notification.ticketCategory!);

    if (notification.type == 'new_ticket') {
      return [
        if (notification.openedBy != null) 'Aberto por ${notification.openedBy}',
        if (category != null) category,
      ].join(' · ');
    }
    if (notification.type == 'new_message') {
      return [
        if (notification.senderName != null) 'Mensagem de ${notification.senderName}',
        if (category != null) category,
      ].join(' · ');
    }
    return notification.body == notification.ticketTitle
        ? ''
        : notification.body;
  }

  Future<void> _deleteTicketFromDashboard(TicketModel ticket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apagar chamado?'),
        content: Text('O chamado #${ticket.id} e todo o histórico serão apagados.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD93045)),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _ticketService.deleteTicket(ticket.id);
      await _loadData(showLoading: false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chamado apagado.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
    }
  }

  bool get _isTecnico => _user?.role.toLowerCase() == 'tecnico';

  List<TicketModel> get _filteredTickets {
    return _tickets.where((ticket) {
      final normalizedStatus =
          ticket.status.toLowerCase().replaceAll('_', ' ').replaceAll('í', 'i');
      final matchesSearch =
          _searchController.text.isEmpty ||
          ticket.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          ticket.id.toString().contains(_searchController.text);

      if (_selectedFilter == 'Todos') return matchesSearch;
      if (_selectedFilter == 'Pendentes' || _selectedFilter == 'Abertos') {
        return matchesSearch && ticket.status.toLowerCase() == 'pendente';
      }
      if (_selectedFilter == 'Em Andamento' || _selectedFilter == 'Em Ação') {
        return matchesSearch && normalizedStatus == 'em andamento';
      }
      if (_selectedFilter == 'Concluídos' || _selectedFilter == 'Resolvidos') {
        return matchesSearch && normalizedStatus == 'concluido';
      }

      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      body: Container(
        // Fundo com gradiente radial estilo 'nublado'
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
              maxWidth: 1180,
              alignment: Alignment.topCenter,
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeHeader(
                        user: _user,
                        isTecnico: _isTecnico,
                        onProfileTap: _openProfile,
                        onNotificationsTap: _showNotifications,
                        unreadCount: _unreadCount,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      HomeWelcomeCard(
                        user: _user,
                        isTecnico: _isTecnico,
                        totalTickets: _tickets.length,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      HomeMetrics(tickets: _tickets, isTecnico: _isTecnico),
                      const SizedBox(height: AppSpacing.md),

                      // Barra de busca
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: _isTecnico
                                ? 'Buscar por título ou ID...'
                                : 'Buscar por ID, assunto ou palavra-chave...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      HomeFilterChips(
                        selectedFilter: _selectedFilter,
                        isTecnico: _isTecnico,
                        onFilterSelected: (filter) {
                          setState(() => _selectedFilter = filter);
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Lista de Chamados
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isTecnico
                                ? 'Chamados Recentes'
                                : 'Meus Chamados Recentes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${_filteredTickets.length} solicitações',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      if (_filteredTickets.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              'Nenhum chamado encontrado.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth > 760 ? 2 : 1;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredTickets.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: 184,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.sm,
                              ),
                              itemBuilder: (context, index) {
                                final ticket = _filteredTickets[index];
                                return TicketCard(
                                  ticket: ticket,
                                  onTap: () => _openTicketDetails(ticket),
                                  onDelete: _user == null ? null : () => _deleteTicketFromDashboard(ticket),
                                  highlightAsNew: _isTecnico && ticket.isNewForTechnician,
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: !_isTecnico
          ? FloatingActionButton.extended(
              onPressed: _openTicketForm,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Novo Chamado',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
