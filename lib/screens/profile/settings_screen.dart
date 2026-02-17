import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          // Seção: Conta
          _buildSectionHeader(context, 'Conta'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Editar Perfil'),
            subtitle: const Text('Nome e foto de perfil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              if (result == true) {
                // Perfil atualizado
              }
            },
          ),
          const Divider(),

          // Seção: Privacidade
          _buildSectionHeader(context, 'Privacidade'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Exercícios Privados'),
            subtitle: const Text('Gerenciar visibilidade dos exercícios'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configure ao criar/editar exercícios')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Perfil Público'),
            subtitle: const Text('Seu perfil é visível para todos'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidade em breve')),
                );
              },
            ),
          ),
          const Divider(),

          // Seção: Notificações
          _buildSectionHeader(context, 'Notificações'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Reações'),
            subtitle: const Text('Quando alguém reage aos seus exercícios'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidade em breve')),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.comment),
            title: const Text('Comentários'),
            subtitle: const Text('Quando alguém comenta'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidade em breve')),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Novos Seguidores'),
            subtitle: const Text('Quando alguém te segue'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidade em breve')),
                );
              },
            ),
          ),
          const Divider(),

          // Seção: Sobre
          _buildSectionHeader(context, 'Sobre'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Versão'),
            subtitle: const Text('RepFlow 1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ajuda'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em breve: Central de ajuda')),
              );
            },
          ),
          const Divider(),

          // Sair
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sair'),
                  content: const Text('Tem certeza que deseja sair?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                final authProvider = context.read<AuthProvider>();
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
