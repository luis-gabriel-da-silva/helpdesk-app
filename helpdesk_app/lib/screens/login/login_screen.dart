import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/helpdesk_logo.dart';
import '../../widgets/responsive_container.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        context.goNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fundo com gradiente suave (Efeito nublado/iluminado roxo e branco)
        decoration: const BoxDecoration(
          gradient: AppTheme.loginBackgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ResponsiveContainer(
                  maxWidth: AppSpacing.maxWidthLogin,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo + Subtítulo principal
                        const SizedBox(height: AppSpacing.lg),
                        const HelpdeskLogo(scale: 2.8),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          AppStrings.appSlogan,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.custom(
                            fontSize: AppTextStyles.fontSize15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Card Principal de Login
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXxl,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withValues(
                                alpha: AppColors.opacity14,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: AppColors.opacity16,
                                ),
                                blurRadius: AppSpacing.xl,
                                offset: const Offset(
                                  AppSpacing.zero,
                                  AppSpacing.space14,
                                ),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tag AppStrings.loginPortal
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.space14,
                                    vertical: AppSpacing.space6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: AppColors.opacity10,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusXl,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: AppSpacing.sm,
                                        height: AppSpacing.sm,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        AppStrings.loginPortal,
                                        style: AppTextStyles.custom(
                                          color: AppColors.primary,
                                          fontSize: AppTextStyles.fontSize13,
                                          fontWeight: AppTextStyles.semiBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Título
                                Text(
                                  AppStrings.loginTitle,
                                  style: AppTextStyles.custom(
                                    fontSize: AppTextStyles.fontSize24,
                                    fontWeight: AppTextStyles.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),

                                // Label E-mail
                                Text(
                                  AppStrings.emailLabel,
                                  style: AppTextStyles.custom(
                                    fontSize: AppTextStyles.fontSize14,
                                    fontWeight: AppTextStyles.semiBold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.email,
                                  decoration: InputDecoration(
                                    hintText: AppStrings.emailHint,
                                    hintStyle: AppTextStyles.custom(
                                      color: AppColors.textSecondary.withValues(
                                        alpha: AppColors.opacity60,
                                      ),
                                      fontSize: AppTextStyles.fontSize14,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.account_circle_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Header Senha + Link Esqueci minha senha
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppStrings.passwordLabel,
                                      style: AppTextStyles.custom(
                                        fontSize: AppTextStyles.fontSize14,
                                        fontWeight: AppTextStyles.semiBold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(AppStrings.needHelp),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        AppStrings.forgotPassword,
                                        style: AppTextStyles.custom(
                                          fontSize: AppTextStyles.fontSize13,
                                          fontWeight: AppTextStyles.semiBold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  validator: (v) => Validators.minLength(
                                    v,
                                    6,
                                    AppStrings.passwordValidationLabel,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: AppStrings.passwordHint,
                                    hintStyle: AppTextStyles.custom(
                                      color: AppColors.textSecondary.withValues(
                                        alpha: AppColors.opacity60,
                                      ),
                                      fontSize: AppTextStyles.fontSize14,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),

                                // Checkbox Lembrar Dispositivo
                                Row(
                                  children: [
                                    SizedBox(
                                      height: AppSpacing.lg,
                                      width: AppSpacing.lg,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            _rememberMe = val ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        AppStrings.rememberDevice,
                                        style: AppTextStyles.custom(
                                          fontSize: AppTextStyles.fontSize13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xl),

                                // Botão Entrar
                                SizedBox(
                                  width: double.infinity,
                                  height: AppSpacing.space54,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusLg,
                                        ),
                                      ),
                                      elevation: AppSpacing.zero,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: AppSpacing.space22,
                                            width: AppSpacing.space22,
                                            child: CircularProgressIndicator(
                                              color: AppColors.surface,
                                              strokeWidth:
                                                  AppSpacing.progressStroke,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                AppStrings.loginButton,
                                                style: AppTextStyles.custom(
                                                  fontSize:
                                                      AppTextStyles.fontSize16,
                                                  fontWeight:
                                                      AppTextStyles.bold,
                                                  color: AppColors.surface,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.space12,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  AppSpacing.xs,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surface
                                                      .withValues(
                                                        alpha:
                                                            AppColors.opacity20,
                                                      ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: AppSpacing.space18,
                                                  color: AppColors.surface,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.helpPrompt,
                              style: AppTextStyles.custom(
                                fontSize: AppTextStyles.fontSize13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Row(
                                children: [
                                  Text(
                                    AppStrings.supportLink,
                                    style: AppTextStyles.custom(
                                      fontSize: AppTextStyles.fontSize13,
                                      fontWeight: AppTextStyles.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.space2),
                                  Icon(
                                    Icons.north_east_rounded,
                                    size: AppSpacing.space13,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          AppStrings.termsAndPrivacy,
                          style: AppTextStyles.custom(
                            fontSize: AppTextStyles.fontSize12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
