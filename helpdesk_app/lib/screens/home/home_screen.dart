import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/ticket_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/ticket_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _ticketService = TicketService();
  final _searchController = TextEditingController();

  UserModel? _user;
  List<TicketModel> _tickets = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getSavedUser();
      final tickets = await _ticketService.getTickets();

      setState(() {
        _user = user;
        _tickets = tickets;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  bool get _isTecnico => _user?.role.toLowerCase() == 'tecnico';

  List<TicketModel> get _filteredTickets {
    return _tickets.where((ticket) {
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
        return matchesSearch && ticket.status.toLowerCase() == 'em andamento';
      }
      if (_selectedFilter == 'Concluídos' || _selectedFilter == 'Resolvidos') {
        return matchesSearch && ticket.status.toLowerCase() == 'concluído';
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
      backgroundColor: const Color(0xFFF9F8FD),
      floatingActionButton: !_isTecnico
          ? FloatingActionButton.extended(
              onPressed: () => context.goNamed(AppRoutes.ticketForm),
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
      body: SafeArea(
        child: Center(
          child: ResponsiveContainer(
            maxWidth: 600,
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
                    // Header Superior
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.md),

                    // Card de Boas-Vindas
                    _buildWelcomeCard(),
                    const SizedBox(height: AppSpacing.md),

                    // Cards de Métricas / Contadores
                    _buildMetricsSection(),
                    const SizedBox(height: AppSpacing.md),

                    // Campo de Pesquisa
                    _buildSearchBar(),
                    const SizedBox(height: AppSpacing.md),

                    // Chips de Filtro
                    _buildFilterChips(),
                    const SizedBox(height: AppSpacing.lg),

                    // Título da Seção
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

                    // Lista de Chamados
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
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredTickets.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final ticket = _filteredTickets[index];
                          return TicketCard(
                            ticket: ticket,
                            onTap: () => context.goNamed(
                              AppRoutes.ticketDetail,
                              pathParameters: {'id': ticket.id.toString()},
                            ),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGETS DE SUPORTE ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _isTecnico ? 'Dashboard' : 'Dashboard Do Cliente',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isTecnico ? 'TÉCNICO' : 'HELPDESK',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () {},
            ),
            GestureDetector(
              onTap: () {
                if (_user != null) {
                  context.goNamed(
                    AppRoutes.profile,
                    pathParameters: {'id': _user!.id.toString()},
                  );
                }
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  _user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Olá, ${_user?.name.split(' ').first ?? 'Usuário'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(!_isTecnico ? '👋' : ''),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _isTecnico ? 'Técnico' : 'Perfil Cliente',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _isTecnico
                      ? '⚡ ${_tickets.length} chamados sob seu monitoramento hoje'
                      : 'Acompanhe o andamento das suas solicitações em tempo real',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    final pending = _tickets
        .where((t) => t.status.toLowerCase() == 'pendente')
        .length;
    final progress = _tickets
        .where((t) => t.status.toLowerCase() == 'em andamento')
        .length;
    final done = _tickets
        .where((t) => t.status.toLowerCase() == 'concluído')
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: _isTecnico ? 'Pendentes' : 'Abertos',
            value: pending.toString(),
            subtitle: _isTecnico ? '' : 'Aguardando',
            icon: Icons.hourglass_empty_rounded,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _buildMetricCard(
            title: _isTecnico ? 'Andamento' : 'Em Ação',
            value: progress.toString(),
            subtitle: _isTecnico ? '' : 'Em análise',
            icon: Icons.sync_rounded,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _buildMetricCard(
            title: _isTecnico ? 'Concluído' : 'Finalizados',
            value: done.toString(),
            subtitle: _isTecnico ? '' : 'Este mês',
            icon: Icons.check_circle_outline_rounded,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 16, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: _isTecnico
              ? 'Buscar por título ou ID...'
              : 'Buscar por ID, assunto ou palavra-chave...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = _isTecnico
        ? ['Todos', 'Pendentes', 'Em Andamento', 'Concluídos']
        : ['Todos', 'Abertos', 'Em Ação', 'Resolvidos'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedFilter = filter);
              },
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 1 && !_isTecnico) {
          // Clique no 'Portal Cliente'
        } else if ((index == 1 && _isTecnico) || (index == 2 && !_isTecnico)) {
          if (_user != null) {
            context.goNamed(
              AppRoutes.profile,
              pathParameters: {'id': _user!.id.toString()},
            );
          }
        }
      },
      items: _isTecnico
          ? const [
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_outlined),
                label: 'Chamados',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: 'Configurações',
              ),
            ]
          : const [
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_outlined),
                label: 'Chamados',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.space_dashboard_outlined),
                label: 'Portal Cliente',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                label: 'Perfil',
              ),
            ],
    );
  }
}
