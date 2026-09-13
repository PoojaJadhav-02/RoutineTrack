import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';
import '../../domain/repositories/task_repository.dart';

class ReminderController extends ChangeNotifier {
  final NotificationService _notificationService;
  bool _isReminderEnabled = true;
  bool _isPermissionGranted = false;
  bool _isLoading = false;

  ReminderController({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService();

  bool get isReminderEnabled => _isReminderEnabled;
  bool get isPermissionGranted => _isPermissionGranted;
  bool get isLoading => _isLoading;

  Future<void> initialize(TaskRepository repository) async {
    _isLoading = true;
    notifyListeners();

    _isReminderEnabled = await _notificationService.isReminderEnabled();
    _isPermissionGranted = await _notificationService.isPermissionGranted();

    if (_isReminderEnabled && _isPermissionGranted) {
      await _notificationService.syncDailyReminder(repository);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleReminder(bool value, TaskRepository repository) async {
    _isReminderEnabled = value;
    notifyListeners();

    if (value && !_isPermissionGranted) {
      final granted = await _notificationService.requestPermission();
      _isPermissionGranted = granted;
    }

    await _notificationService.setReminderEnabled(value, repository);
    notifyListeners();
  }

  Future<bool> requestPermission(TaskRepository repository) async {
    final granted = await _notificationService.requestPermission();
    _isPermissionGranted = granted;
    if (granted && _isReminderEnabled) {
      await _notificationService.syncDailyReminder(repository);
    }
    notifyListeners();
    return granted;
  }

  Future<void> syncReminder(TaskRepository repository) async {
    if (_isReminderEnabled) {
      await _notificationService.syncDailyReminder(repository);
    }
  }

  Future<void> triggerTestNotification(int pendingCount) async {
    await _notificationService.showTestNotification(pendingCount: pendingCount);
  }
}
