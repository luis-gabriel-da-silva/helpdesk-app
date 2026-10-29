import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../services/ticket_service.dart';
import '../../widgets/responsive_container.dart';

class TicketFormScreen extends StatefulWidget {
  const TicketFormScreen({super.key});

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TicketService _ticketService = TicketService();

  String _selectedCategory = 'hardware';
  String _selectedPriority = 'media';
  bool _isLoading = false;

  // Variáveis para gestão de anexo (Mobile vs Web)
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
    // Na v13, pickFiles retorna diretamente List<PlatformFile>
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );

    // Se o utilizador cancelou a seleção, a lista vem vazia
    if (files.isEmpty || !mounted) return;

    final file = files.first;

    // Na Web lê os bytes assincronamente com readAsBytes()
    final bytes = kIsWeb ? await file.readAsBytes() : null;
    if (!mounted) return;

    setState(() {
      _fileName = file.name;
      if (kIsWeb) {
        _fileBytes = bytes;
        _filePath = null;
      } else {
        _filePath = file.path;
        _fileBytes = null;
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _ticketService.createTicket(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        description: _descriptionController.text.trim(),
        filePath: _filePath,
        fileBytes: _fileBytes,
        fileName: _fileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chamado aberto com sucesso!'),
            backgroundColor: AppColors.statusConcluido,
          ),
        );
        context.pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.newTicket)),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 600,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título
                  TextFormField(
                    controller: _titleController,
                    validator: (v) => Validators.requiredField(v, 'O título'),
                    decoration: const InputDecoration(
                      labelText: AppStrings.titleLabel,
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Categoria
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: AppStrings.categoryLabel,
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'hardware',
                        child: Text(AppStrings.catHardware),
                      ),
                      DropdownMenuItem(
                        value: 'login',
                        child: Text(AppStrings.catLogin),
                      ),
                      DropdownMenuItem(
                        value: 'db_infra',
                        child: Text(AppStrings.catDbInfra),
                      ),
                      DropdownMenuItem(
                        value: 'financeiro',
                        child: Text(AppStrings.catFinanceiro),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Prioridade
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: AppStrings.priorityLabel,
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'baixa', child: Text('Baixa')),
                      DropdownMenuItem(value: 'media', child: Text('Média')),
                      DropdownMenuItem(value: 'alta', child: Text('Alta')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPriority = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Descrição
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    validator: (v) =>
                        Validators.minLength(v, 10, 'A descrição'),
                    decoration: const InputDecoration(
                      labelText: AppStrings.descriptionLabel,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Selecionar Anexo
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file_rounded),
                    label: Text(
                      _fileName ?? AppStrings.addAttachment,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Botão Submeter
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(AppStrings.saveButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
