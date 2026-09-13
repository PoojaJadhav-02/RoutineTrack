import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/local/task_local_data_source.dart';
import 'data/repositories/task_repository_impl.dart';
import 'domain/repositories/task_repository.dart';
import 'presentation/controllers/reminder_controller.dart';
import 'presentation/controllers/task_controller.dart';
import 'presentation/controllers/theme_controller.dart';
import 'presentation/screens/home_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistence and repositories
  final localDataSource = TaskLocalDataSourceImpl();
  final taskRepository = TaskRepositoryImpl(localDataSource: localDataSource);

  // Initialize ThemeController
  final themeController = ThemeController();
  await themeController.initialize();

  // Initialize TaskController
  final taskController = TaskController(repository: taskRepository);

  // Initialize NotificationService with tap response
  await NotificationService().initialize(
    onNotificationTap: (payload) {
      if (payload == AppConstants.notificationPayloadOpenToday) {
        taskController.goToToday();
      }
    },
  );

  // Initialize ReminderController
  final reminderController = ReminderController();
  await reminderController.initialize(taskRepository);

  // Load initial tasks and sync reminder
  await taskController.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<TaskRepository>.value(value: taskRepository),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
        ChangeNotifierProvider<TaskController>.value(value: taskController),
        ChangeNotifierProvider<ReminderController>.value(value: reminderController),
      ],
      child: const DailyFlowApp(),
    ),
  );
}

class DailyFlowApp extends StatelessWidget {
  const DailyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      title: 'DailyFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      home: const HomeNavigationScreen(),
    );
  }
}
