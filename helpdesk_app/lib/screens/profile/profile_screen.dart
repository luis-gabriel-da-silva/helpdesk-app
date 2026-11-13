import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/helpdesk_logo.dart';
import '../../widgets/responsive_container.dart';
import 'widgets/corporate_info_card.dart';
import 'widgets/notification_settings_card.dart';
import 'widgets/profile_header_card.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _maxPhotoSize = 5 * 1024 * 1024;

  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _positionController = TextEditingController();

  UserModel? _user;
  String _department = AppStrings.departmentGeneral;
  Uint8List? _photoBytes;
  String? _photoName;
  String? _photoPath;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refreshHeader);
    _positionController.addListener(_refreshHeader);
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _refreshHeader() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile() async {
    try {
      final savedUser = await _authService.getSavedUser();
      if (!mounted) return;
      _user = savedUser;
      if (savedUser != null) {
        _nameController.text = savedUser.name;
        _emailController.text = savedUser.email;
        _positionController.text = savedUser.position;
        _department = savedUser.department;
      }
      setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );
      if (files.isEmpty || !mounted) return;

      final file = files.first;
      final size = await file.length();
      if (!mounted) return;
      if (size == null || size > _maxPhotoSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              size == null
                  ? AppStrings.profileImageSizeError
                  : AppStrings.profileImageTooLarge,
            ),
          ),
        );
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoName = file.name;
        _photoPath = file.path;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.imageOpenErrorMessage(error))),
      );
    }
  }

  Future<void> _saveChanges() async {
    final currentUser = _user;
    if (currentUser == null) return;
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _positionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.fillProfileFields)),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updatedUser = await _authService.updateProfile(
        UserModel(
          id: currentUser.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          role: currentUser.role,
          position: _positionController.text.trim(),
          department: _department,
          avatarUrl: currentUser.avatarUrl,
        ),
        avatarBytes: _photoBytes,
        avatarPath: _photoPath,
        avatarName: _photoName,
      );
      if (!mounted) return;
      _user = updatedUser;
      _photoBytes = null;
      _photoPath = null;
      if (context.canPop()) {
        context.pop(updatedUser);
      } else {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.profileUpdated)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveProfileError)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _authService.logout();
      if (mounted) context.goNamed(AppRoutes.login);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoggingOut = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.logoutError)));
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppStrings.goBack,
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(AppStrings.profileTitle),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: HelpdeskLogo(scale: 0.85),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.cloudyBackgroundGradient,
        ),
        child: SafeArea(
          top: false,
          child: ResponsiveContainer(
            maxWidth: AppSpacing.maxWidthProfile,
            alignment: Alignment.topCenter,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _user == null
                ? const Center(child: Text(AppStrings.profileNotFound))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide =
                          constraints.maxWidth >
                          AppSpacing.breakpointProfileWide;
                      final leftColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfileHeaderCard(
                            name: _nameController.text,
                            position: _positionController.text,
                            employeeCode:
                                '#HD-${_user!.id.toString().padLeft(4, '0')}',
                            photoBytes: _photoBytes,
                            photoUrl: _user!.avatarUrl == null
                                ? null
                                : _authService.resolveAvatarUrl(
                                    _user!.avatarUrl!,
                                  ),
                            onChangePhoto: _pickPhoto,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          CorporateInfoCard(
                            nameController: _nameController,
                            emailController: _emailController,
                            positionController: _positionController,
                            employeeCode:
                                '#HD-${_user!.id.toString().padLeft(4, '0')}',
                            department: _department,
                            onDepartmentChanged: (value) {
                              if (value != null) {
                                setState(() => _department = value);
                              }
                            },
                          ),
                        ],
                      );
                      final notificationCard = NotificationSettingsCard(
                        emailEnabled: _emailNotifications,
                        pushEnabled: _pushNotifications,
                        onEmailChanged: (value) =>
                            setState(() => _emailNotifications = value),
                        onPushChanged: (value) =>
                            setState(() => _pushNotifications = value),
                      );
                      final actions = _buildActions();
                      final rightColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          notificationCard,
                          const SizedBox(height: AppSpacing.md),
                          actions,
                        ],
                      );

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: leftColumn),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(child: rightColumn),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ProfileHeaderCard(
                                    name: _nameController.text,
                                    position: _positionController.text,
                                    employeeCode:
                                        '#HD-${_user!.id.toString().padLeft(4, '0')}',
                                    photoBytes: _photoBytes,
                                    photoUrl: _user!.avatarUrl == null
                                        ? null
                                        : _authService.resolveAvatarUrl(
                                            _user!.avatarUrl!,
                                          ),
                                    onChangePhoto: _pickPhoto,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  CorporateInfoCard(
                                    nameController: _nameController,
                                    emailController: _emailController,
                                    positionController: _positionController,
                                    employeeCode:
                                        '#HD-${_user!.id.toString().padLeft(4, '0')}',
                                    department: _department,
                                    onDepartmentChanged: (value) {
                                      if (value != null) {
                                        setState(() => _department = value);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  notificationCard,
                                  const SizedBox(height: AppSpacing.md),
                                  actions,
                                ],
                              ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: AppSpacing.space52,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveChanges,
            icon: _isSaving
                ? const SizedBox(
                    height: AppSpacing.space18,
                    width: AppSpacing.space18,
                    child: CircularProgressIndicator(
                      color: AppColors.surface,
                      strokeWidth: AppSpacing.space2,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? AppStrings.saving : AppStrings.saveProfile),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              shape: const StadiumBorder(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: _isLoggingOut ? null : _logout,
          icon: _isLoggingOut
              ? const SizedBox(
                  height: AppSpacing.space18,
                  width: AppSpacing.space18,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSpacing.space2,
                  ),
                )
              : const Icon(Icons.logout_rounded),
          label: Text(
            _isLoggingOut ? AppStrings.disconnecting : AppStrings.disconnect,
          ),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
        ),
      ],
    );
  }
}
