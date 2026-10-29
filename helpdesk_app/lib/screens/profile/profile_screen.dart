import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/responsive_container.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final savedUser = await _authService.getSavedUser();
      if (mounted) {
        setState(() {
          _user = savedUser;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileTitle)),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 500,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _user == null
              ? const Center(child: Text('Perfil não encontrado.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Text(
                          _user!.name.isNotEmpty
                              ? _user!.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(_user!.name, style: AppTextStyles.titleLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _user!.email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildProfileInfoTile(
                        icon: Icons.work_outline,
                        label: AppStrings.positionLabel,
                        value: _user!.position,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildProfileInfoTile(
                        icon: Icons.business_outlined,
                        label: AppStrings.departmentLabel,
                        value: _user!.department,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildProfileInfoTile(
                        icon: Icons.admin_panel_settings_outlined,
                        label: AppStrings.roleLabel,
                        value: _user!.role == 'tecnico'
                            ? 'Técnico de Suporte'
                            : 'Cliente / Utilizador',
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}
