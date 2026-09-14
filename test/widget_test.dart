import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:routinetrack/core/services/notification_service.dart';
import 'package:routinetrack/core/theme/app_theme.dart';
import 'package:routinetrack/core/utils/date_utils.dart';
import 'package:routinetrack/core/utils/time_utils.dart';
import 'package:routinetrack/data/local/task_local_data_source.dart';
import 'package:routinetrack/data/models/task_model.dart';
import 'package:routinetrack/data/repositories/task_repository_impl.dart';
import 'package:routinetrack/domain/entities/task.dart';
import 'package:routinetrack/domain/repositories/task_repository.dart';
import 'package:routinetrack/presentation/controllers/reminder_controller.dart';
import 'package:routinetrack/presentation/controllers/task_controller.dart';
import 'package:routinetrack/presentation/controllers/theme_controller.dart';
import 'package:routinetrack/presentation/screens/home_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockTaskLocalDataSource implements TaskLocalDataSource {
  List<TaskModel> tasks = [];

  @override
  Future<List<TaskModel>> getSavedTasks() async {
    return List.from(tasks);
  }

  @override
  Future<void> saveTasks(List<TaskModel> newTasks) async {
    tasks = List.from(newTasks);
  }

  @override
  Future<void> clearTasks() async {
    tasks.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('Date & Time Utils Tests', () {
    test('AppDateUtils normalizes dates to midnight', () {
      final dt = DateTime(2026, 9, 13, 14, 30, 45);
      final normalized = AppDateUtils.normalize(dt);
      expect(normalized.year, 2026);
      expect(normalized.month, 9);
      expect(normalized.day, 13);
      expect(normalized.hour, 0);
      expect(normalized.minute, 0);
      expect(normalized.second, 0);
    });

    test('AppDateUtils toKey and fromKey work symmetrically', () {
      final dt = DateTime(2026, 9, 13);
      final key = AppDateUtils.toKey(dt);
      expect(key, '2026-09-13');
      final parsed = AppDateUtils.fromKey(key);
      expect(parsed, AppDateUtils.normalize(dt));
    });

    test('AppTimeUtils serialization and parsing', () {
      const time = TimeOfDay(hour: 6, minute: 30);
      final storage = AppTimeUtils.toStorageString(time);
      expect(storage, '06:30');
      final parsed = AppTimeUtils.fromStorageString(storage);
      expect(parsed?.hour, 6);
      expect(parsed?.minute, 30);
    });

    test('AppTimeUtils comparison', () {
      const early = TimeOfDay(hour: 6, minute: 30);
      const late = TimeOfDay(hour: 8, minute: 0);
      expect(AppTimeUtils.compareTimeOfDay(early, late), lessThan(0));
      expect(AppTimeUtils.compareTimeOfDay(late, early), greaterThan(0));
      expect(AppTimeUtils.compareTimeOfDay(early, early), equals(0));
    });
  });

  group('Notification Message Dynamic Requirements', () {
    test('Single pending task produces exact singular message', () {
      final body = NotificationService.getReminderBody(1);
      expect(
        body,
        "You still have 1 task left for today. Don't forget to complete it!",
      );
    });

    test('Multiple pending tasks produces exact plural count message', () {
      final body3 = NotificationService.getReminderBody(3);
      expect(
        body3,
        "You still have 3 tasks left for today. Complete them before the day ends!",
      );

      final body5 = NotificationService.getReminderBody(5);
      expect(
        body5,
        "You still have 5 tasks left for today. Complete them before the day ends!",
      );
    });
  });

  group('TaskRepositoryImpl Tests', () {
    late MockTaskLocalDataSource mockDataSource;
    late TaskRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockTaskLocalDataSource();
      repository = TaskRepositoryImpl(localDataSource: mockDataSource);
    });

    test('Adding and retrieving tasks by date isolates tasks by date', () async {
      final date1 = DateTime(2026, 9, 13);
      final date2 = DateTime(2026, 9, 14);

      final task1 = Task(
        id: '1',
        title: 'Morning Yoga',
        date: date1,
        time: const TimeOfDay(hour: 7, minute: 0),
        createdAt: DateTime(2026, 9, 13, 6, 0),
      );

      final task2 = Task(
        id: '2',
        title: 'Office Work',
        date: date2,
        time: const TimeOfDay(hour: 9, minute: 0),
        createdAt: DateTime(2026, 9, 14, 8, 0),
      );

      await repository.addTask(task1);
      await repository.addTask(task2);

      final date1Tasks = await repository.getTasksByDate(date1);
      expect(date1Tasks.length, 1);
      expect(date1Tasks.first.title, 'Morning Yoga');

      final date2Tasks = await repository.getTasksByDate(date2);
      expect(date2Tasks.length, 1);
      expect(date2Tasks.first.title, 'Office Work');
    });

    test('Sorting orders timed tasks first chronologically, then untimed', () async {
      final date = DateTime(2026, 9, 13);

      final taskUntimed = Task(
        id: '1',
        title: 'Untimed task',
        date: date,
        time: null,
        createdAt: DateTime(2026, 9, 13, 10, 0),
      );

      final taskLate = Task(
        id: '2',
        title: 'Evening Run',
        date: date,
        time: const TimeOfDay(hour: 18, minute: 30),
        createdAt: DateTime(2026, 9, 13, 11, 0),
      );

      final taskEarly = Task(
        id: '3',
        title: 'Morning Run',
        date: date,
        time: const TimeOfDay(hour: 6, minute: 30),
        createdAt: DateTime(2026, 9, 13, 12, 0),
      );

      await repository.addTask(taskUntimed);
      await repository.addTask(taskLate);
      await repository.addTask(taskEarly);

      final tasks = await repository.getTasksByDate(date);
      expect(tasks.length, 3);
      expect(tasks[0].title, 'Morning Run');
      expect(tasks[1].title, 'Evening Run');
      expect(tasks[2].title, 'Untimed task');
    });

    test('Toggling task completion updates isCompleted and completedAt', () async {
      final date = DateTime(2026, 9, 13);
      final task = Task(
        id: 'toggle-1',
        title: 'Drink 2L Water',
        date: date,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await repository.addTask(task);
      await repository.toggleTask('toggle-1');

      var tasks = await repository.getTasksByDate(date);
      expect(tasks.first.isCompleted, true);
      expect(tasks.first.completedAt, isNotNull);

      await repository.toggleTask('toggle-1');
      tasks = await repository.getTasksByDate(date);
      expect(tasks.first.isCompleted, false);
      expect(tasks.first.completedAt, isNull);
    });

    test('Updating task modifies values and does not duplicate', () async {
      final date = DateTime(2026, 9, 13);
      final task = Task(
        id: 'update-1',
        title: 'Original Title',
        date: date,
        createdAt: DateTime.now(),
      );

      await repository.addTask(task);
      final updated = task.copyWith(title: 'Modified Title');
      await repository.updateTask(updated);

      final tasks = await repository.getTasksByDate(date);
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Modified Title');
    });

    test('Deleting task removes it permanently', () async {
      final date = DateTime(2026, 9, 13);
      final task = Task(
        id: 'del-1',
        title: 'To be deleted',
        date: date,
        createdAt: DateTime.now(),
      );

      await repository.addTask(task);
      expect((await repository.getTasksByDate(date)).length, 1);

      await repository.deleteTask('del-1');
      expect((await repository.getTasksByDate(date)).isEmpty, true);
    });
  });

  group('Widget and Screen Integration Tests', () {
    testWidgets('App renders Today & History tabs and navigates correctly',
        (tester) async {
      final mockDataSource = MockTaskLocalDataSource();
      final repository = TaskRepositoryImpl(localDataSource: mockDataSource);

      final today = AppDateUtils.normalize(DateTime.now());
      await repository.addTask(Task(
        id: 'w-1',
        title: 'Meditation Habit',
        description: 'Breathe deeply',
        date: today,
        time: const TimeOfDay(hour: 7, minute: 0),
        isCompleted: false,
        createdAt: DateTime.now(),
      ));

      final themeController = ThemeController();
      final taskController = TaskController(repository: repository);
      final reminderController = ReminderController();
      await taskController.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TaskRepository>.value(value: repository),
            ChangeNotifierProvider<ThemeController>.value(value: themeController),
            ChangeNotifierProvider<TaskController>.value(value: taskController),
            ChangeNotifierProvider<ReminderController>.value(value: reminderController),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const HomeNavigationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check title & Today tab components
      expect(find.text('DailyFlow'), findsOneWidget);
      expect(find.text('Today'), findsWidgets);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Meditation Habit'), findsOneWidget);

      // Check Daily Progress Card
      expect(find.text("Today's Progress"), findsOneWidget);
      expect(find.text('0 completed · 1 remaining'), findsOneWidget);

      // Toggle task completion
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      expect(find.text('1 completed · 0 remaining'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.textContaining('All tasks completed'), findsOneWidget);

      // Switch to History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.text('History'), findsWidgets);
      expect(find.text('Meditation Habit'), findsOneWidget);

      // Open Reminder Settings Sheet
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Settings & Reminders'), findsOneWidget);
      expect(find.text('Daily Pending Task Reminder'), findsOneWidget);
      expect(find.textContaining('Remind me at 9:00 PM'), findsOneWidget);

      // Close bottom sheet
      Navigator.of(tester.element(find.text('Settings & Reminders'))).pop();
      await tester.pumpAndSettle();

      // Delete task from History tab
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Delete task?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Meditation Habit'), findsNothing);
      expect(find.text('No routine history yet'), findsOneWidget);
    });
  });
}
