import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
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
import 'widgets/home_search_bar.dart';
import 'widgets/home_welcome_card.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';

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
  String? _loadError;
  String _selectedFilter = AppStrings.filterAll;

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
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (_tickets.isEmpty) _loadError = AppStrings.errorLoadingTickets;
      });
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
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text(AppStrings.profileUpdated)));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.ticketDeleted)));
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
        title: Row(
          children: [
            const Expanded(child: Text(AppStrings.notificationsTitle)),
            if (_unreadCount > 0)
              Text(
                AppStrings.unreadNotificationCount(_unreadCount),
                style: AppTextStyles.custom(
                  fontSize: AppTextStyles.fontSize12,
                  color: AppColors.dangerAccent,
                ),
              ),
          ],
        ),
        content: SizedBox(
          width: AppSpacing.notificationDialogWidth,
          height: AppSpacing.notificationDialogHeight,
          child: _notifications.isEmpty
              ? const Center(child: Text(AppStrings.notificationEmpty))
              : ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: AppSpacing.hairline),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                        horizontal: AppSpacing.space2,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: notification.isRead
                            ? AppColors.surfaceMuted
                            : AppColors.dangerSurface,
                        child: Icon(
                          notification.title.toLowerCase().contains('mensagem')
                              ? Icons.chat_bubble_outline_rounded
                              : Icons.confirmation_number_outlined,
                          color: notification.isRead
                              ? AppColors.primary
                              : AppColors.danger,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: AppTextStyles.custom(
                          fontWeight: notification.isRead
                              ? AppTextStyles.medium
                              : AppTextStyles.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${notification.ticketTitle}\n${_notificationDetails(notification)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      onTap: () =>
                          Navigator.of(dialogContext).pop(notification),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.close),
          ),
        ],
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
        if (notification.openedBy != null)
          '${AppStrings.openedBy} ${notification.openedBy}',
        ?category,
      ].join(' · ');
    }
    if (notification.type == 'new_message') {
      return [
        if (notification.senderName != null)
          '${AppStrings.messageFrom} ${notification.senderName}',
        ?category,
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
        title: Text(AppStrings.deleteTicketTitle),
        content: Text(AppStrings.ticketDeleteConfirmation(ticket.id)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _ticketService.deleteTicket(ticket.id);
      await _loadData(showLoading: false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.ticketDeleted)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  bool get _isTecnico => _user?.role.toLowerCase() == 'tecnico';

  List<TicketModel> get _filteredTickets {
    return _tickets.where((ticket) {
      final normalizedStatus = ticket.status
          .toLowerCase()
          .replaceAll('_', ' ')
          .replaceAll('í', 'i');
      final matchesSearch =
          _searchController.text.isEmpty ||
          ticket.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          ticket.id.toString().contains(_searchController.text);

      if (_selectedFilter == AppStrings.filterAll) return matchesSearch;
      if (_selectedFilter == AppStrings.filterPending ||
          _selectedFilter == AppStrings.filterOpen) {
        return matchesSearch && ticket.status.toLowerCase() == 'pendente';
      }
      if (_selectedFilter == AppStrings.filterInProgress ||
          _selectedFilter == AppStrings.filterInAction) {
        return matchesSearch && normalizedStatus == 'em andamento';
      }
      if (_selectedFilter == AppStrings.filterCompleted ||
          _selectedFilter == AppStrings.filterResolved) {
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

    if (_loadError != null && _tickets.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        // Fundo com gradiente radial estilo 'nublado'
        decoration: const BoxDecoration(
          gradient: AppTheme.cloudyBackgroundGradient,
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ResponsiveContainer(
              maxWidth: AppSpacing.maxWidthHome,
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

                      HomeSearchBar(
                        controller: _searchController,
                        isTecnico: _isTecnico,
                        onChanged: (_) => setState(() {}),
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
                                ? AppStrings.recentTickets
                                : AppStrings.myRecentTickets,
                            style: AppTextStyles.custom(
                              fontSize: AppTextStyles.fontSize16,
                              fontWeight: AppTextStyles.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${_filteredTickets.length} ${AppStrings.ticketCountLabel}',
                            style: AppTextStyles.custom(
                              fontSize: AppTextStyles.fontSize12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      if (_filteredTickets.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.xl,
                          ),
                          child: Center(
                            child: Text(
                              AppStrings.emptyTickets,
                              style: AppTextStyles.custom(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns =
                                constraints.maxWidth >
                                    AppSpacing.breakpointTicketGrid
                                ? 2
                                : 1;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredTickets.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    mainAxisExtent: AppSpacing.ticketCardExtent,
                                    crossAxisSpacing: AppSpacing.md,
                                    mainAxisSpacing: AppSpacing.sm,
                                  ),
                              itemBuilder: (context, index) {
                                final ticket = _filteredTickets[index];
                                return TicketCard(
                                  ticket: ticket,
                                  onTap: () => _openTicketDetails(ticket),
                                  onDelete: _user == null
                                      ? null
                                      : () =>
                                            _deleteTicketFromDashboard(ticket),
                                  highlightAsNew:
                                      _isTecnico && ticket.isNewForTechnician,
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
              icon: const Icon(Icons.add, color: AppColors.surface),
              label: Text(
                AppStrings.newTicket,
                style: AppTextStyles.custom(
                  color: AppColors.surface,
                  fontWeight: AppTextStyles.bold,
                ),
              ),
            )
          : null,
    );
  }
}
