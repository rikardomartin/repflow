import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/groups_service.dart';
import '../../utils/firebase_auth_extensions.dart';
import 'group_members_screen.dart';
import 'edit_group_screen.dart';
import 'group_feed_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupsService _groupsService = GroupsService();
  bool _isMember = false;
  bool _isAdmin = false;
  bool _isLoading = true;
  bool _isJoining = false;
  late Group _currentGroup;

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.group;
    _checkMembership();
  }

  Future<void> _checkMembership() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id;

    if (userId != null) {
      final isMember = await _groupsService.isUserMember(widget.group.id, userId);
      final isAdmin = await _groupsService.isUserAdmin(widget.group.id, userId);
      setState(() {
        _isMember = isMember;
        _isAdmin = isAdmin;
        _isLoading = false;
      });
    }
  }

  Future<void> _reloadGroup() async {
    try {
      // Buscar grupo específico diretamente do banco
      final data = await _groupsService.fetchGroupById(widget.group.id);
      if (data != null) {
        setState(() {
          _currentGroup = data;
        });
      }
    } catch (e) {
      print('Erro ao recarregar grupo: $e');
    }
  }

  Future<void> _toggleMembership() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id;

    if (userId == null) return;

    setState(() => _isJoining = true);

    try {
      if (_isMember) {
        await _groupsService.leaveGroup(widget.group.id, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Você saiu do grupo')),
          );
        }
      } else {
        await _groupsService.joinGroup(widget.group.id, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Você entrou no grupo!')),
          );
        }
      }

      setState(() {
        _isMember = !_isMember;
      });
      
      // Aguardar trigger executar no banco
      await Future.delayed(const Duration(milliseconds: 500));
      
      await _reloadGroup();
      await _checkMembership();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isJoining = false);
    }
  }

  Future<void> _editGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditGroupScreen(group: _currentGroup),
      ),
    );
    
    if (result == true) {
      await _reloadGroup();
    }
  }

  Future<void> _deleteGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Grupo'),
        content: Text('Tem certeza que deseja excluir "${_currentGroup.name}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _groupsService.deleteGroup(widget.group.id);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Grupo excluído')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String emoji = '📁';
    switch (widget.group.type) {
      case 'academia':
        emoji = '🏋️';
        break;
      case 'bairro':
        emoji = '🏘️';
        break;
      case 'time':
        emoji = '⚽';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          if (_isAdmin) ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editGroup();
                } else if (value == 'delete') {
                  _deleteGroup();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Editar Grupo'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Excluir Grupo', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Group header
            Container(
              padding: const EdgeInsets.all(32),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentGroup.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (_currentGroup.description != null && _currentGroup.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _currentGroup.description!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupMembersScreen(
                            groupId: _currentGroup.id,
                            groupName: _currentGroup.name,
                          ),
                        ),
                      );
                    },
                    child: _buildStat(
                      context,
                      Icons.people,
                      '${_currentGroup.membersCount}',
                      'Membros',
                    ),
                  ),
                  _buildStat(
                    context,
                    Icons.fitness_center,
                    '${_currentGroup.exercisesCount}',
                    'Exercícios',
                  ),
                ],
              ),
            ),

            // Join/Leave button
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _isJoining ? null : _toggleMembership,
                  icon: Icon(_isMember ? Icons.exit_to_app : Icons.group_add),
                  label: Text(_isMember ? 'Sair do Grupo' : 'Entrar no Grupo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: _isMember ? Colors.red : null,
                    foregroundColor: _isMember ? Colors.white : null,
                  ),
                ),
              ),

            const Divider(),

            // Group exercises section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercícios do Grupo',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isMember)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Entre no grupo para ver os exercícios',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GroupFeedScreen(
                              groupId: _currentGroup.id,
                              groupName: _currentGroup.name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.fitness_center),
                      label: Text('Ver Exercícios (${_currentGroup.exercisesCount})'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
