import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/task_controller.dart';
import '../widgets/daily_flow_logo.dart';
import '../widgets/reminder_settings_sheet.dart';
import 'history/history_screen.dart';
import 'today/today_screen.dart';

class HomeNavigationScreen extends StatefulWidget {
  const HomeNavigationScreen({super.key});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToTodayWithDate(DateTime date) {
    final taskController = context.read<TaskController>();
    taskController.setSelectedDate(date);
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 54,
        titleSpacing: 18,
        title: const DailyFlowLogo(
          size: 28,
          fontSize: 19,
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications & Settings',
            icon: const Icon(Icons.notifications_none_rounded, size: 23),
            onPressed: () => ReminderSettingsSheet.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const TodayScreen(),
          HistoryScreen(
            onNavigateToDate: _navigateToTodayWithDate,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline_rounded),
              selectedIcon: Icon(Icons.check_circle_rounded),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.access_time_rounded),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
