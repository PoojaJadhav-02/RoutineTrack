import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/repositories/task_repository.dart';
import '../controllers/reminder_controller.dart';
import '../controllers/task_controller.dart';
import '../controllers/theme_controller.dart';

class ReminderSettingsSheet extends StatelessWidget {
  const ReminderSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color ?? Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const ReminderSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminderController = context.watch<ReminderController>();
    final themeController = context.watch<ThemeController>();
    final taskController = context.watch<TaskController>();
    final taskRepo = context.read<TaskRepository>();

    final today = AppDateUtils.normalize(DateTime.now());
    final isTodaySelected = taskController.selectedDate == today;
    final int todayPending = isTodaySelected
        ? taskController.pendingTasks
        : taskController.selectedDateTasks
            .where((t) =>
                AppDateUtils.normalize(t.date) == today && !t.isCompleted)
            .length;

    final isEnabled = reminderController.isReminderEnabled;
    final isPermGranted = reminderController.isPermissionGranted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Settings & Reminders',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Daily 9 PM Reminder Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Pending Task Reminder',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Remind me at 9:00 PM',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isEnabled,
                  onChanged: (val) {
                    reminderController.toggleReminder(val, taskRepo);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Status indication
          if (!isEnabled)
            _buildInfoNote(
              'Reminder is turned OFF. You won\'t receive 9:00 PM alerts.',
              theme,
            )
          else if (!isPermGranted)
            _buildInfoNote(
              'Notification permission is needed for reminders.',
              theme,
              action: TextButton(
                onPressed: () => reminderController.requestPermission(taskRepo),
                child: const Text('Grant Permission', style: TextStyle(fontSize: 12)),
              ),
            )
          else if (todayPending == 0)
            _buildInfoNote(
              'All today\'s tasks completed — no 9 PM reminder needed 🎉',
              theme,
            )
          else
            _buildInfoNote(
              'Active: 9:00 PM reminder scheduled ($todayPending pending).',
              theme,
            ),

          const SizedBox(height: 16),

          // Appearance / Theme Mode Selector (Default Light)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.light_mode_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.dark_mode_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.brightness_auto_outlined, size: 16),
                    ),
                  ],
                  selected: {themeController.themeMode},
                  onSelectionChanged: (newSelection) {
                    themeController.setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Test notification button
          OutlinedButton.icon(
            onPressed: () async {
              final count = todayPending > 0 ? todayPending : 3;
              await reminderController.triggerTestNotification(count);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Test notification sent ($count tasks)'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.send_outlined, size: 16),
            label: const Text('Send Test Notification', style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote(String text, ThemeData theme, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
