import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

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

  static const _departments = [
    'Tecnologia',
    'Infraestrutura',
    'Financeiro',
    'Recursos Humanos',
    'Operações',
    'Geral',
  ];

  @override
  Widget build(BuildContext context) {
    final options = {..._departments, department}.toList()..sort();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dados Corporativos', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSpacing.md),
          _field('Nome Completo', nameController),
          const SizedBox(height: AppSpacing.sm),
          _field(
            'E-mail Corporativo',
            emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: department,
            decoration: const InputDecoration(
              labelText: 'Setor / Departamento',
              prefixIcon: Icon(Icons.business_outlined),
            ),
            items: options
                .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: onDepartmentChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          _field('Cargo', positionController),
          const SizedBox(height: AppSpacing.sm),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Matrícula',
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
      prefixIcon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
    ),
  );

  static final _cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.primary.withOpacity(0.12)),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.14),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
