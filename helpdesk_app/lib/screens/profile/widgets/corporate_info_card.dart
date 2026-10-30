import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';

class CorporateInfoCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController positionController;
  final String employeeCode;
  final String department;
  final ValueChanged<String?> onDepartmentChanged;

  const CorporateInfoCard({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.positionController,
    required this.employeeCode,
    required this.department,
    required this.onDepartmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = {...AppStrings.departments, department}.toList()..sort();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.corporateData, style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSpacing.md),
          _field(AppStrings.fullName, nameController),
          const SizedBox(height: AppSpacing.sm),
          _field(
            AppStrings.corporateEmail,
            emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: department,
            decoration: const InputDecoration(
              labelText: AppStrings.departmentFullLabel,
              prefixIcon: Icon(Icons.business_outlined),
            ),
            items: options
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: onDepartmentChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          _field(AppStrings.positionLabel, positionController),
          const SizedBox(height: AppSpacing.sm),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: AppStrings.employeeId,
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            child: Text(employeeCode),
          ),
        ],
      ),
    );
  }

  static Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(
        Icons.edit_outlined,
        color: AppColors.textSecondary,
      ),
    ),
  );

  static final _cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
    border: Border.all(
      color: AppColors.primary.withValues(alpha: AppColors.opacity12),
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: AppColors.opacity14),
        blurRadius: AppSpacing.space20,
        offset: const Offset(AppSpacing.zero, AppSpacing.space6),
      ),
    ],
  );
}
