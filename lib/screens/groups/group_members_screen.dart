import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/groups_service.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/firebase_auth_extensions.dart';

class GroupMembersScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupMembersScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  final GroupsService _groupsService = GroupsService();
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      _currentUserId = authProvider.user?.id;

      print('DEBUG: Carregando membros do grupo ${widget.groupId}');

      // Verificar se é admin
      if (_currentUserId != null) {
        _isAdmin = await _groupsService.isUserAdmin(widget.groupId, _currentUserId!);
        print('DEBUG: Usuário é admin: $_isAdmin');
      }

      // Buscar membros do grupo
      final members = await _groupsService.fetchGroupMembers(widget.groupId);
      print('DEBUG: Membros encontrados: ${members.length}');

      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('DEBUG: Erro ao carregar membros: $e');
      print('DEBUG: Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar membros: $e')),
        );
      }
    }
  }

  Future<void> _removeMember(String userId, String displayName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Membro'),
        content: Text('Tem certeza que deseja remover $displayName do grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _groupsService.removeMember(widget.groupId, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$displayName removido do grupo')),
          );
          _loadMembers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao remover: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Membros - ${widget.groupName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? const Center(child: Text('Nenhum membro ainda'))
              : RefreshIndicator(
                  onRefresh: _loadMembers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      final user = member['users'] as Map<String, dynamic>?;
                      final role = member['role'] as String;
                      final joinedAt = DateTime.parse(member['joined_at'] as String);

                      if (user == null) return const SizedBox.shrink();

                      final displayName = user['display_name'] as String? ?? 'Usuário';
                      final profileImageUrl = user['profile_image_url'] as String?;
                      final initials = displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'U';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: UserAvatar(
                            initials: initials,
                            imageUrl: profileImageUrl,
                            radius: 24,
                          ),
                          title: Text(
                            displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(_formatDate(joinedAt)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildRoleBadge(role),
                              if (_isAdmin && user['id'] != _currentUserId) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeMember(user['id'] as String, displayName),
                                  tooltip: 'Remover membro',
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    String label;

    switch (role) {
      case 'admin':
        color = Colors.red;
        label = 'Admin';
        break;
      case 'moderator':
        color = Colors.orange;
        label = 'Moderador';
        break;
      default:
        color = Colors.blue;
        label = 'Membro';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Entrou hoje';
    } else if (diff.inDays == 1) {
      return 'Entrou ontem';
    } else if (diff.inDays < 7) {
      return 'Entrou há ${diff.inDays} dias';
    } else if (diff.inDays < 30) {
      return 'Entrou há ${(diff.inDays / 7).floor()} semanas';
    } else {
      return 'Entrou há ${(diff.inDays / 30).floor()} meses';
    }
  }
}
