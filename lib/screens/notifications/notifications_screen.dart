import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../services/firestore_service.dart'; 
import '../exercise/exercise_detail_screen.dart';
import '../profile/user_profile_screen.dart';

// CONVERTIDO PARA STATELESSWIDGET
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Ações agora recebem o context para acessar os providers
  Future<void> _handleNotificationTap(BuildContext context, AppNotification notification) async {
    final notificationsProvider = context.read<NotificationsProvider>();
    
    // Tenta obter o FirestoreService a partir do context (assumindo que está provido)
    // Se não estiver, precisará ser criado ou acessado de outra forma.
    final firestoreService = FirestoreService(); 

    // Marcar como lida via provider
    await notificationsProvider.markAsRead(notification.id);

    if (!context.mounted) return;

    // Navegação baseada no tipo de notificação
    if (notification.type == NotificationType.follow) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UserProfileScreen(userId: notification.fromUserId)),
      );
    } else if (notification.exerciseId != null) {
      final exercise = await firestoreService.fetchExerciseById(notification.exerciseId!);
      if (exercise != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: exercise)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assiste às mudanças no NotificationsProvider
    final notificationsProvider = context.watch<NotificationsProvider>();
    final authProvider = context.read<AuthProvider>(); // read é suficiente aqui

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          // Botão só aparece se houver notificações não lidas
          if (notificationsProvider.unreadCount > 0)
            TextButton(
              onPressed: () {
                if (authProvider.user?.id != null) {
                  notificationsProvider.markAllAsRead(authProvider.user!.id);
                }
              },
              child: const Text('Marcar todas como lidas'),
            ),
        ],
      ),
      body: _buildNotificationsList(context, notificationsProvider),
    );
  }

  Widget _buildNotificationsList(BuildContext context, NotificationsProvider provider) {
    // Usa o estado de isLoading do provider
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Usa a lista de notificações do provider
    if (provider.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Nenhuma notificação', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.notifications.length,
      itemBuilder: (context, index) {
        final notification = provider.notifications[index];
        return _buildNotificationItem(context, notification);
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context, AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // A exclusão também deve, idealmente, passar pelo provider
        // context.read<NotificationsProvider>().deleteNotification(notification.id);
      },
      child: ListTile(
        leading: _buildIcon(notification.type),
        title: Text(
          _buildMessage(notification),
          style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: Text(_formatDate(notification.timestamp)),
        trailing: !notification.isRead
            ? Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              )
            : null,
        onTap: () => _handleNotificationTap(context, notification),
        tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      ),
    );
  }

    // Funções auxiliares (Helpers)
  Icon _buildIcon(NotificationType type) {
    switch (type) {
      case NotificationType.follow:
        return const Icon(Icons.person_add, color: Colors.blue);
      case NotificationType.like:
        return const Icon(Icons.favorite, color: Colors.red);
      case NotificationType.comment:
        return const Icon(Icons.comment, color: Colors.green);
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  String _buildMessage(AppNotification notification) {
    final fromUserName = notification.fromUserName;
    final exerciseName = notification.text;
    switch (notification.type) {
      case NotificationType.follow:
        return '$fromUserName começou a te seguir';
      case NotificationType.like:
        return '$fromUserName reagiu ao seu exercício${exerciseName != null ? ' "$exerciseName"' : ''}';
      case NotificationType.comment:
        return '$fromUserName comentou no seu exercício${exerciseName != null ? ' "$exerciseName"' : ''}';
      default:
        return 'Nova notificação';
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inHours < 1) return 'Há ${diff.inMinutes}min';
    if (diff.inDays < 1) return 'Há ${diff.inHours}h';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
    return 'Em ${date.day}/${date.month}';
  }
}
