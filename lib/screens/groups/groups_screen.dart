import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/groups_service.dart';
import '../../utils/firebase_auth_extensions.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GroupsService _groupsService = GroupsService();
  
  List<Group> _myGroups = [];
  List<Group> _publicGroups = [];
  bool _isLoadingMy = true;
  bool _isLoadingPublic = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id;

    if (userId != null) {
      setState(() {
        _isLoadingMy = true;
        _isLoadingPublic = true;
      });

      try {
        final myGroups = await _groupsService.fetchUserGroups(userId);
        final publicGroups = await _groupsService.fetchPublicGroups();

        setState(() {
          _myGroups = myGroups;
          _publicGroups = publicGroups;
          _isLoadingMy = false;
          _isLoadingPublic = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingMy = false;
          _isLoadingPublic = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Meus Grupos'),
            Tab(text: 'Descobrir'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyGroupsTab(),
          _buildDiscoverTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          );
          if (result == true) {
            _loadGroups();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Criar Grupo'),
      ),
    );
  }

  Widget _buildMyGroupsTab() {
    if (_isLoadingMy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Você ainda não participa de nenhum grupo',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Descubra grupos ou crie o seu!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myGroups.length,
        itemBuilder: (context, index) {
          return _buildGroupCard(_myGroups[index], isMember: true);
        },
      ),
    );
  }

  Widget _buildDiscoverTab() {
    if (_isLoadingPublic) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_publicGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Nenhum grupo público ainda',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _publicGroups.length,
        itemBuilder: (context, index) {
          final group = _publicGroups[index];
          final isMember = _myGroups.any((g) => g.id == group.id);
          return _buildGroupCard(group, isMember: isMember);
        },
      ),
    );
  }

  Widget _buildGroupCard(Group group, {required bool isMember}) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupDetailScreen(group: group),
            ),
          );
          if (result == true) {
            _loadGroups();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Group icon/image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (group.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        group.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${group.membersCount} membros',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${group.exercisesCount} exercícios',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Member badge
              if (isMember)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Membro',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
