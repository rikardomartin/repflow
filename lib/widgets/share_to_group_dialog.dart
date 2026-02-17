import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../providers/auth_provider.dart';
import '../services/groups_service.dart';
import '../utils/firebase_auth_extensions.dart';

class ShareToGroupDialog extends StatefulWidget {
  final String exerciseId;

  const ShareToGroupDialog({super.key, required this.exerciseId});

  @override
  State<ShareToGroupDialog> createState() => _ShareToGroupDialogState();
}

class _ShareToGroupDialogState extends State<ShareToGroupDialog> {
  final GroupsService _groupsService = GroupsService();
  List<Group> _myGroups = [];
  bool _isLoading = true;
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _loadMyGroups();
  }

  Future<void> _loadMyGroups() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id;

    if (userId != null) {
      try {
        final groups = await _groupsService.fetchUserGroups(userId);
        setState(() {
          _myGroups = groups;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _shareToGroup() async {
    if (_selectedGroupId == null) return;

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id;

    if (userId == null) return;

    try {
      await _groupsService.shareExerciseInGroup(
        groupId: _selectedGroupId!,
        exerciseId: widget.exerciseId,
        sharedBy: userId,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercício compartilhado no grupo!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Compartilhar no Grupo'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : _myGroups.isEmpty
              ? const Text('Você não participa de nenhum grupo ainda.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Selecione um grupo:'),
                    const SizedBox(height: 16),
                    ...List.generate(_myGroups.length, (index) {
                      final group = _myGroups[index];
                      String emoji = '📁';
                      switch (group.type) {
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

                      return RadioListTile<String>(
                        value: group.id,
                        groupValue: _selectedGroupId,
                        onChanged: (value) {
                          setState(() => _selectedGroupId = value);
                        },
                        title: Text('$emoji ${group.name}'),
                        subtitle: Text('${group.membersCount} membros'),
                      );
                    }),
                  ],
                ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        if (!_isLoading && _myGroups.isNotEmpty)
          ElevatedButton(
            onPressed: _selectedGroupId == null ? null : _shareToGroup,
            child: const Text('Compartilhar'),
          ),
      ],
    );
  }
}
