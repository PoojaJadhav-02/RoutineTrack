import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../domain/repositories/task_repository.dart';
import '../constants/app_constants.dart';
import '../utils/date_utils.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  void Function(String? payload)? _onTapCallback;

  FlutterLocalNotificationsPlugin get plugin => _notificationsPlugin;

  /// Initializes the local notification plugin and local timezone
  Future<void> initialize({void Function(String? payload)? onNotificationTap}) async {
    if (_isInitialized) return;
    _onTapCallback = onNotificationTap;

    // Initialize timezones
    try {
      tz.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      debugPrint('Error detecting timezone, falling back to local: $e');
    }

    // Android Initialization Settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/Darwin Initialization Settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (_onTapCallback != null) {
          _onTapCallback!(response.payload);
        }
      },
    );

    // Create high importance Android notification channel
    const channel = AndroidNotificationChannel(
      AppConstants.dailyReminderChannelId,
      AppConstants.dailyReminderChannelName,
      description: AppConstants.dailyReminderChannelDesc,
      importance: Importance.high,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
  }

  /// Check if notification permission is granted
  Future<bool> isPermissionGranted() async {
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final bool? granted = await androidImpl.areNotificationsEnabled();
      return granted ?? false;
    }

    final iosImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final permissions = await iosImpl.checkPermissions();
      return permissions?.isEnabled ?? false;
    }

    return true;
  }

  /// Request notification permission (e.g. POST_NOTIFICATIONS for Android 13+)
  Future<bool> requestPermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.reminderPermissionRequestedKey, true);

    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final bool? granted =
          await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final bool? granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Check if the user has enabled the 9 PM reminder in settings
  Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true
    return prefs.getBool(AppConstants.reminderEnabledStorageKey) ?? true;
  }

  /// Set reminder enabled status
  Future<void> setReminderEnabled(bool enabled, TaskRepository repository) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.reminderEnabledStorageKey, enabled);

    if (enabled) {
      await syncDailyReminder(repository);
    } else {
      await cancelDailyReminder();
    }
  }

  /// Formats the reminder notification body based on pending task count
  static String getReminderBody(int pendingCount) {
    if (pendingCount == 1) {
      return "You still have 1 task left for today. Don't forget to complete it!";
    } else {
      return "You still have $pendingCount tasks left for today. Complete them before the day ends!";
    }
  }

  /// Schedules the 9:00 PM reminder with the dynamic incomplete tasks count
  Future<void> scheduleDaily9PmReminder({
    required int pendingCount,
    required DateTime date,
  }) async {
    if (!_isInitialized) return;
    if (pendingCount <= 0) {
      await cancelDailyReminder();
      return;
    }

    final scheduledTime = _nextInstanceOf9Pm();
    final body = getReminderBody(pendingCount);

    const androidDetails = AndroidNotificationDetails(
      AppConstants.dailyReminderChannelId,
      AppConstants.dailyReminderChannelName,
      channelDescription: AppConstants.dailyReminderChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    // Cancel existing reminder first to prevent any duplicate IDs
    try {
      await _notificationsPlugin.cancel(id: AppConstants.dailyReminderNotificationId);
    } catch (_) {}

    try {
      await _notificationsPlugin.zonedSchedule(
        id: AppConstants.dailyReminderNotificationId,
        title: 'DailyFlow Reminder 🔔',
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: notificationDetails,
        payload: AppConstants.notificationPayloadOpenToday,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Scheduled 9 PM reminder for $scheduledTime with message: "$body"');
    } catch (e) {
      debugPrint('Error scheduling 9 PM reminder: $e');
    }
  }

  /// Cancels the daily 9 PM reminder
  Future<void> cancelDailyReminder() async {
    if (!_isInitialized) return;
    try {
      await _notificationsPlugin.cancel(id: AppConstants.dailyReminderNotificationId);
      debugPrint('Canceled 9 PM reminder (ID: ${AppConstants.dailyReminderNotificationId})');
    } catch (e) {
      debugPrint('Error canceling 9 PM reminder: $e');
    }
  }

  /// Synchronizes the 9 PM reminder based on today's current stored tasks:
  /// - If reminder is disabled in settings: cancel
  /// - If total tasks == 0 or incomplete tasks == 0: cancel
  /// - If incomplete tasks > 0: schedule with exact pending count
  Future<void> syncDailyReminder(TaskRepository repository) async {
    final enabled = await isReminderEnabled();
    if (!enabled) {
      await cancelDailyReminder();
      return;
    }

    final today = AppDateUtils.normalize(DateTime.now());
    final todayTasks = await repository.getTasksByDate(today);

    final incompleteCount = todayTasks.where((t) => !t.isCompleted).length;

    if (incompleteCount == 0) {
      // Either 0 total tasks or all tasks completed: Do NOT send notification
      await cancelDailyReminder();
    } else {
      // Send reminder with dynamic count
      await scheduleDaily9PmReminder(
        pendingCount: incompleteCount,
        date: today,
      );
    }
  }

  /// Triggers an immediate notification for testing the exact 9 PM reminder message
  Future<void> showTestNotification({required int pendingCount}) async {
    final body = getReminderBody(pendingCount);

    const androidDetails = AndroidNotificationDetails(
      AppConstants.dailyReminderChannelId,
      AppConstants.dailyReminderChannelName,
      channelDescription: AppConstants.dailyReminderChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: AppConstants.dailyReminderNotificationId,
      title: 'DailyFlow Reminder 🔔',
      body: body,
      notificationDetails: notificationDetails,
      payload: AppConstants.notificationPayloadOpenToday,
    );
  }

  /// Calculates the next instance of 9:00 PM (21:00) in local timezone
  tz.TZDateTime _nextInstanceOf9Pm() {
    try {
      tz.local;
    } catch (_) {
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      AppConstants.reminderHour,
      AppConstants.reminderMinute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
