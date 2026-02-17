import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notifications_service.dart';

class NotificationsProvider with ChangeNotifier {
  final NotificationsService _notificationsService = NotificationsService();
  
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _unreadCountSubscription;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Carrega as notificações do usuário e ouve as atualizações
  void loadUserNotifications(String userId) {
    // Se já estivermos ouvindo, cancelamos para evitar duplicatas
    dispose();

    _isLoading = true;
    notifyListeners();

    // Ouvir o stream de notificações
    _notificationsSubscription = _notificationsService.getUserNotificationsStream(userId).listen((notifications) {
      _notifications = notifications;
      if (_isLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }, onError: (error) {
      print("Erro ao carregar notificações: $error");
      _isLoading = false;
      notifyListeners();
    });

    // Ouvir o stream da contagem de não lidos
    _unreadCountSubscription = _notificationsService.getUnreadCountStream(userId).listen((count) {
      _unreadCount = count;
      notifyListeners();
    }, onError: (error) {
      print("Erro ao carregar contagem de não lidos: $error");
    });
  }

  // Marca uma notificação como lida
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsService.markAsRead(notificationId);
      // A atualização da contagem virá do stream, não precisa chamar notifyListeners()
    } catch (e) {
      print('Erro ao marcar notificação como lida: $e');
    }
  }

  // Marca todas as notificações como lidas
  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationsService.markAllAsRead(userId);
      // A atualização da contagem virá do stream
    } catch (e) {
      print('Erro ao marcar todas as notificações como lidas: $e');
    }
  }

  // Limpa os listeners quando o provider for descartado
  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.dispose();
  }
}
