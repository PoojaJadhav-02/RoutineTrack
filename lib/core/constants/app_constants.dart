class AppConstants {
  static const String appName = 'DailyFlow';
  static const String tasksStorageKey = 'routine_track_tasks_v1';
  static const String themeStorageKey = 'routine_track_theme_mode_v1';
  static const String reminderEnabledStorageKey = 'routine_track_reminder_enabled_v1';
  static const String reminderPermissionRequestedKey = 'routine_track_permission_requested_v1';

  // Notification Constants
  static const int dailyReminderNotificationId = 9001;
  static const String dailyReminderChannelId = 'daily_pending_tasks';
  static const String dailyReminderChannelName = 'Daily Task Reminder';
  static const String dailyReminderChannelDesc =
      'Reminds about pending routine tasks every day at 9:00 PM';

  static const int reminderHour = 21; // 9:00 PM
  static const int reminderMinute = 0;
  static const String notificationPayloadOpenToday = 'open_today';
}
