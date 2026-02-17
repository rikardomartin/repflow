import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/groups_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/firebase_auth_extensions.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final GroupsService _groupsService = GroupsService();
  
  String _selectedType = 'academia';
  bool _isPublic = true;
  bool _isLoading = false;

  final Map<String, String> _groupTypes = {
    'academia': '🏋️ Academia',
    'bairro': '🏘️ Bairro',
    'time': '⚽ Time',
    'outro': '📁 Outro',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user!.id;

      await _groupsService.createGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        type: _selectedType,
        createdBy: userId,
        isPublic: _isPublic,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grupo criado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar grupo: $e'),
            backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: const Text('Criar Grupo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group icon preview
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      _groupTypes[_selectedType]!.split(' ')[0],
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Name
              CustomTextField(
                controller: _nameController,
                label: 'Nome do Grupo',
                hint: 'Ex: Academia Fitness Center',
                prefixIcon: Icons.group,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome do grupo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Grupo',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _groupTypes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Descrição (opcional)',
                hint: 'Descreva o propósito do grupo...',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Public toggle
              SwitchListTile(
                title: const Text('Grupo Público'),
                subtitle: const Text(
                  'Qualquer pessoa pode encontrar e entrar',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Create button
              CustomButton(
                text: 'Criar Grupo',
                onPressed: _createGroup,
                isLoading: _isLoading,
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
