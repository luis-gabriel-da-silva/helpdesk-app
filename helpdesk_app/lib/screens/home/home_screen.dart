import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
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
  final TicketService _ticketService = TicketService();
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  List<TicketModel> _allTickets = [];
  List<TicketModel> _filteredTickets = [];

  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'todos';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getSavedUser();
      final tickets = await _ticketService.getTickets();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _allTickets = tickets;
          _applyFilters();
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

  void _applyFilters() {
    setState(() {
      _filteredTickets = _allTickets.where((ticket) {
        final matchesSearch = ticket.title.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );

        final matchesStatus =
            _selectedStatus == 'todos' || ticket.status == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      context.goNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              if (_currentUser != null) {
                context.pushNamed(
                  AppRoutes.profile,
                  pathParameters: {'id': _currentUser!.id.toString()},
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.pushNamed(AppRoutes.ticketForm);
          _loadData(); // Recarrega os chamados ao voltar da tela de criação
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Chamado',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 700,
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  // Barra de Busca
                  TextField(
                    onChanged: (value) {
                      _searchQuery = value;
                      _applyFilters();
                    },
                    decoration: const InputDecoration(
                      hintText: AppStrings.searchPlaceholder,
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Filtros por Status (Chips)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todos', 'todos'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('Pendentes', 'pendente'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('Em Andamento', 'em_andamento'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('Concluídos', 'concluido'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Lista de Chamados
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredTickets.isEmpty
                        ? const Center(
                            child: Text(
                              AppStrings.emptyTickets,
                              style: AppTextStyles.bodyMedium,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredTickets.length,
                            itemBuilder: (context, index) {
                              final ticket = _filteredTickets[index];
                              return TicketCard(
                                ticket: ticket,
                                onTap: () async {
                                  await context.pushNamed(
                                    AppRoutes.ticketDetail,
                                    pathParameters: {
                                      'id': ticket.id.toString(),
                                    },
                                  );
                                  _loadData();
                                },
                              );
                            },
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatus = value;
            _applyFilters();
          });
        }
      },
    );
  }
}
