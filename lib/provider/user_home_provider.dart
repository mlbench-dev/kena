import 'package:flutter/material.dart';

class UserHomeProvider extends ChangeNotifier {
  int _unreadNotificationCount = 0;

  int get unreadNotificationCount => _unreadNotificationCount;

  void setUnreadNotificationCount(int value) {
    _unreadNotificationCount = value;
    notifyListeners();
  }

  void resetUnreadNotificationCount() {
    _unreadNotificationCount = 0;
    notifyListeners();
  }
}
