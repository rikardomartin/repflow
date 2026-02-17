import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/exercises_provider.dart';
import '../providers/social_provider.dart';
import '../providers/notifications_provider.dart';
import 'home/home_screen.dart';
import 'social/feed_screen.dart';
import 'groups/groups_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FeedScreen(),
    const GroupsScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Garante que o contexto está pronto antes de carregar os dados.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  // Função centralizada para carregar TODOS os dados iniciais do app.
  void _loadInitialData() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      print("DEBUG MainScreen: Carregando dados para userId: ${user.id}");
      
      // 1. Carrega os exercícios do usuário
      context.read<ExercisesProvider>().loadUserExercises(user.id);
      print("DEBUG MainScreen: Exercícios carregados");

      // 2. Inicializa o feed social público
      context.read<SocialProvider>().initializeSocialFeed();

      // 3. Carrega as notificações do usuário (A CORREÇÃO PRINCIPAL)
      context.read<NotificationsProvider>().loadUserNotifications(user.id);
      print("DEBUG MainScreen: Notificações carregadas");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercícios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
