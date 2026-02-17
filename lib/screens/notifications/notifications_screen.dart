import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notifications_service.dart';
import '../../utils/firebase_auth_extensions.dart';
import '../exercise/exercise_detail_screen.dart';
import '../profile/user_profile_screen.dart';
import '../../services/firestore_service.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsService _notificationsService = NotificationsService();
  final FirestoreService _firestoreService = FirestoreService();
  
  @override
  void initState() {
    super.initState();
  }

  Future<void> _markAllAsRead() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.id;

    if (userId != null) {
      await _notificationsService.markAllAsRead(userId);
    }
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    final notificationId = notification.id;
    final type = notification.type;
    final exerciseId = notification.exerciseId;
    final fromUserId = notification.fromUserId;

    // Marcar como lida
    // Marcar como lida
    await _notificationsService.markAsRead(notificationId);

    // Navegar para a tela apropriada
    if (mounted) {
      if (type == NotificationType.follow) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(userId: fromUserId),
          ),
        );
      } else if (exerciseId != null) {
        // Buscar exercício e navegar
        final exercise = await _firestoreService.fetchExerciseById(exerciseId);
        if (exercise != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExerciseDetailScreen(exercise: exercise),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.user?.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<List<AppNotification>>(
      stream: _notificationsService.getUserNotificationsStream(userId),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final hasUnread = notifications.any((n) => !n.isRead);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notificações'),
            actions: [
              if (hasUnread)
                TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text('Marcar todas como lidas'),
                ),
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 100, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma notificação',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationItem(notification);
                      },
                    ),
        );
      },
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    final type = notification.type;
    final fromUserName = notification.fromUserName;
    final exerciseName = notification.text; 
    final isRead = notification.isRead;
    final createdAt = notification.timestamp;

    IconData icon;
    Color iconColor;
    String message;

    switch (type) {
      case NotificationType.follow:
        icon = Icons.person_add;
        iconColor = Colors.blue;
        message = '$fromUserName começou a te seguir';
        break;
      case NotificationType.like:
        icon = Icons.favorite;
        iconColor = Colors.red;
        message = '$fromUserName reagiu ao seu exercício${exerciseName != null ? ' "$exerciseName"' : ''}';
        break;
      case NotificationType.comment:
        icon = Icons.comment;
        iconColor = Colors.green;
        message = '$fromUserName comentou no seu exercício${exerciseName != null ? ' "$exerciseName"' : ''}';
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
        message = 'Nova notificação';
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await _notificationsService.deleteNotification(notification.id);
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          message,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(_formatDate(createdAt)),
        trailing: !isRead
            ? Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _handleNotificationTap(notification),
        tileColor: isRead ? null : Colors.blue.withOpacity(0.05),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Agora';
    } else if (diff.inHours < 1) {
      return 'Há ${diff.inMinutes}min';
    } else if (diff.inDays < 1) {
      return 'Há ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return 'Há ${diff.inDays} dias';
    } else {
      return 'Há ${(diff.inDays / 7).floor()} semanas';
    }
  }
}
