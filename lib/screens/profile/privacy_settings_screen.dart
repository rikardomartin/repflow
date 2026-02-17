import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/social_service.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final SocialService _socialService = SocialService();
  bool _isPublic = false;
  bool _allowComments = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;

    if (userId != null) {
      try {
        final userProfile = await _socialService.getUserProfile(userId);
        if (userProfile != null && mounted) {
          setState(() {
            _isPublic = userProfile.isPublic;
            _allowComments = userProfile.allowComments;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _updateSetting(String setting, bool value) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) return;

    try {
      final currentProfile = await _socialService.getUserProfile(userId);
      if (currentProfile != null) {
        final updatedProfile = setting == 'isPublic'
            ? currentProfile.copyWith(isPublic: value)
            : currentProfile.copyWith(allowComments: value);
        
        await _socialService.updateUserProfile(updatedProfile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuração atualizada!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Reverter o estado
        setState(() {
          if (setting == 'isPublic') {
            _isPublic = !value;
          } else {
            _allowComments = !value;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidade'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Controle quem pode ver seu perfil e interagir com você',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Perfil Público'),
                        subtitle: const Text(
                          'Permite que outros usuários vejam seu perfil',
                        ),
                        value: _isPublic,
                        onChanged: (value) {
                          setState(() => _isPublic = value);
                          _updateSetting('isPublic', value);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Permitir Comentários'),
                        subtitle: const Text(
                          'Outros usuários podem comentar em seus exercícios públicos',
                        ),
                        value: _allowComments,
                        onChanged: (value) {
                          setState(() => _allowComments = value);
                          _updateSetting('allowComments', value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sobre as configurações:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Perfil Público: Quando ativado, outros usuários podem ver seu perfil e seus exercícios públicos.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Permitir Comentários: Quando ativado, outros usuários podem comentar em seus exercícios públicos.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Seus exercícios privados nunca são visíveis para outros usuários.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
