import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../providers/auth_provider.dart';
import '../../providers/exercises_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/firebase_auth_extensions.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  String _selectedGroup = 'Treino A';
  XFile? _selectedImage;
  bool _isPublic = false;

  final List<String> _trainingGroups = [
    'Treino A',
    'Treino B',
    'Treino C',
    'Treino D',
    'Cardio',
    'Outro',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final exercisesProvider = context.read<ExercisesProvider>();

    final success = await exercisesProvider.addExercise(
      userId: authProvider.user!.id,
      name: _nameController.text.trim(),
      trainingGroup: _selectedGroup,
      instructions: _instructionsController.text.trim(),
      image: _selectedImage,
      isPublic: _isPublic,
    );

    if (success && mounted) {
      // Força reload da lista
      await exercisesProvider.reloadExercises(authProvider.user!.id);
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercício adicionado com sucesso!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exercisesProvider.errorMessage ?? 'Erro ao adicionar exercício'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercisesProvider = context.watch<ExercisesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Exercício'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _selectedImage != null
                      ? FutureBuilder<Uint8List>(
                          future: _selectedImage!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }
                            return const Center(child: CircularProgressIndicator());
                          },
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Adicionar foto da máquina',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Name
              CustomTextField(
                controller: _nameController,
                label: 'Nome do Exercício',
                hint: 'Ex: Supino Reto',
                prefixIcon: Icons.fitness_center,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome do exercício';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Training Group dropdown
              DropdownButtonFormField<String>(
                value: _selectedGroup,
                decoration: const InputDecoration(
                  labelText: 'Grupo de Treino',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _trainingGroups.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGroup = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Instructions
              CustomTextField(
                controller: _instructionsController,
                label: 'Instruções de Execução',
                hint: 'Descreva como executar o exercício...',
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite as instruções';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Public toggle
              SwitchListTile(
                title: const Text('Tornar público'),
                subtitle: const Text(
                  'Outros usuários poderão ver este exercício',
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

              // Save button
              CustomButton(
                text: 'Salvar Exercício',
                onPressed: _handleSave,
                isLoading: exercisesProvider.isLoading,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
