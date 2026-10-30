import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../services/ticket_service.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/helpdesk_logo.dart';
import 'widgets/category_selector.dart';
import 'widgets/file_uploader.dart';
import 'widgets/priority_selector.dart';
import '../../core/constants/app_strings.dart';

import 'package:helpdesk_app/core/theme/app_text_styles.dart';

class TicketFormScreen extends StatefulWidget {
  final String? ticketId;

  const TicketFormScreen({super.key, this.ticketId});

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  static const _maxTitleLength = 80;
  static const _maxFileSize = 15 * 1024 * 1024;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TicketService _ticketService = TicketService();

  String _selectedCategory = 'hardware';
  String _selectedPriority = 'media';
  bool _isLoading = false;
  bool _isLoadingTicket = false;
  String? _loadError;
  String? _filePath;
  Uint8List? _fileBytes;
  String? _fileName;

  bool get _isEditing => widget.ticketId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadTicketForEditing();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTicketForEditing() async {
    setState(() => _isLoadingTicket = true);
    try {
      final ticket = await _ticketService.getTicketById(
        int.parse(widget.ticketId!),
      );
      final originalMessages = ticket.messages
          .where((message) => message.user?.id == ticket.user?.id)
          .toList();
      if (!mounted) return;
      setState(() {
        _titleController.text = ticket.title;
        _descriptionController.text = originalMessages.isEmpty
            ? ''
            : originalMessages.first.message;
        _selectedCategory = ticket.category;
        _selectedPriority = ticket.priority;
        _isLoadingTicket = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString().replaceFirst('Exception: ', '');
        _isLoadingTicket = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'log'],
    );
    if (files.isEmpty || !mounted) return;

    final file = files.first;
    final bytes = kIsWeb ? await file.readAsBytes() : null;
    final fileSize = bytes?.length ?? await file.length();
    if (!mounted) return;
    if (fileSize == null || fileSize > _maxFileSize) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.fileSizeError)));
      return;
    }

    setState(() {
      _fileName = file.name;
      _filePath = kIsWeb ? null : file.path;
      _fileBytes = bytes;
    });
  }

  void _removeFile() {
    setState(() {
      _fileName = null;
      _filePath = null;
      _fileBytes = null;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        await _ticketService.updateTicket(
          ticketId: int.parse(widget.ticketId!),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          category: _selectedCategory,
        );
      } else {
        await _ticketService.createTicket(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          category: _selectedCategory,
          filePath: _filePath,
          fileBytes: _fileBytes,
          fileName: _fileName,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? AppStrings.ticketUpdated : AppStrings.ticketCreated,
          ),
          backgroundColor: AppColors.statusConcluido,
        ),
      );
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.goNamed(AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop(false);
    } else {
      context.goNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTicket) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: AppStrings.goBack,
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text(AppStrings.editTicketAction),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: AppStrings.goBack,
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text(AppStrings.editTicketAction),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!),
              TextButton(
                onPressed: _loadTicketForEditing,
                child: const Text(AppStrings.retry),
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
        title: Text(
          _isEditing ? AppStrings.editTicketAction : AppStrings.openTicket,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: HelpdeskLogo(scale: 0.85),
          ),
        ],
        backgroundColor: AppColors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.cloudyBackgroundGradient,
        ),
        child: SafeArea(
          top: false,
          child: ResponsiveContainer(
            maxWidth: AppSpacing.maxWidthForm,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel(AppStrings.detailedTitle),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${_titleController.text.length}/$_maxTitleLength',
                                style: AppTextStyles.custom(
                                  color: AppColors.textSecondary,
                                  fontSize: AppTextStyles.fontSize12,
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: _titleController,
                            maxLength: _maxTitleLength,
                            onChanged: (_) => setState(() {}),
                            validator: (value) => Validators.requiredField(
                              value,
                              AppStrings.titleValidationLabel,
                            ),
                            decoration: const InputDecoration(
                              hintText: AppStrings.titleHint,
                              counterText: '',
                              prefixIcon: Icon(Icons.title_rounded),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _sectionLabel(AppStrings.categoryLabel),
                          CategorySelector(
                            selectedCategory: _selectedCategory,
                            onChanged: (value) =>
                                setState(() => _selectedCategory = value),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _sectionLabel(AppStrings.priorityLabel),
                          PrioritySelector(
                            selectedPriority: _selectedPriority,
                            onChanged: (value) =>
                                setState(() => _selectedPriority = value),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _sectionLabel(AppStrings.detailedDescription),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            validator: (value) => Validators.minLength(
                              value,
                              10,
                              AppStrings.descriptionValidationLabel,
                            ),
                            decoration: const InputDecoration(
                              alignLabelWithHint: true,
                              hintText: AppStrings.descriptionHint,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (!_isEditing) ...[
                            _sectionLabel(AppStrings.optionalAttachment),
                            FileUploader(
                              fileName: _fileName,
                              onTap: _pickFile,
                              onRemove: _removeFile,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppSpacing.space54,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleSubmit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: AppSpacing.space18,
                              height: AppSpacing.space18,
                              child: CircularProgressIndicator(
                                color: AppColors.surface,
                                strokeWidth: AppSpacing.space2,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _isLoading
                            ? (_isEditing
                                  ? AppStrings.saving
                                  : AppStrings.sending)
                            : (_isEditing
                                  ? AppStrings.saveChanges
                                  : AppStrings.saveButton),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      text,
      style: AppTextStyles.custom(
        fontWeight: AppTextStyles.semiBold,
        color: AppColors.textPrimary,
      ),
    ),
  );
}
