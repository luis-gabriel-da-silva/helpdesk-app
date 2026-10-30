import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../services/ticket_service.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/helpdesk_logo.dart';
import 'widgets/category_selector.dart';
import 'widgets/file_uploader.dart';
import 'widgets/priority_selector.dart';

class TicketFormScreen extends StatefulWidget {
  const TicketFormScreen({super.key});

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
  String? _filePath;
  Uint8List? _fileBytes;
  String? _fileName;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fileSize == null
                ? 'Não foi possível verificar o tamanho do arquivo.'
                : 'O arquivo deve ter no máximo 15 MB.',
          ),
        ),
      );
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
      await _ticketService.createTicket(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        category: _selectedCategory,
        filePath: _filePath,
        fileBytes: _fileBytes,
        fileName: _fileName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chamado aberto com sucesso!'),
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
          backgroundColor: Colors.redAccent,
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Abrir chamado'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: HelpdeskLogo(scale: 0.85),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.45),
            radius: 1.35,
            colors: [Colors.white, Color(0xFFF6F2FC), Color(0xFFEDE6F8)],
            stops: [0.15, 0.65, 1],
          ),
        ),
        child: SafeArea(
          top: false,
          child: ResponsiveContainer(
            maxWidth: 900,
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
                          _sectionLabel('Título do Problema'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${_titleController.text.length}/$_maxTitleLength',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: _titleController,
                            maxLength: _maxTitleLength,
                            onChanged: (_) => setState(() {}),
                            validator: (value) =>
                                Validators.requiredField(value, 'O título'),
                            decoration: const InputDecoration(
                              hintText:
                                  'Ex: Erro ao sincronizar banco de dados',
                              counterText: '',
                              prefixIcon: Icon(Icons.title_rounded),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _sectionLabel('Categoria'),
                          CategorySelector(
                            selectedCategory: _selectedCategory,
                            onChanged: (value) =>
                                setState(() => _selectedCategory = value),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _sectionLabel('Prioridade'),
                          PrioritySelector(
                            selectedPriority: _selectedPriority,
                            onChanged: (value) =>
                                setState(() => _selectedPriority = value),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _sectionLabel('Descrição Detalhada'),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            validator: (value) => Validators.minLength(
                              value,
                              10,
                              'A descrição',
                            ),
                            decoration: const InputDecoration(
                              alignLabelWithHint: true,
                              hintText:
                                  'Descreva o que aconteceu, passos para reproduzir e mensagens de erro...',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _sectionLabel('Anexo (opcional)'),
                          FileUploader(
                            fileName: _fileName,
                            onTap: _pickFile,
                            onRemove: _removeFile,
                          ),
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
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleSubmit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(_isLoading ? 'Enviando...' : 'Abrir Chamado'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
  );
}
