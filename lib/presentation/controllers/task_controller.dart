import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/date_task_summary.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class TaskController extends ChangeNotifier {
  final TaskRepository _repository;

  DateTime _selectedDate = AppDateUtils.normalize(DateTime.now());
  List<Task> _selectedDateTasks = [];
  List<DateTaskSummary> _historySummaries = [];
  DateTime? _historyFilterDate;
  bool _isLoading = false;

  TaskController({required TaskRepository repository}) : _repository = repository;

  DateTime get selectedDate => _selectedDate;
  List<Task> get selectedDateTasks => List.unmodifiable(_selectedDateTasks);
  List<DateTaskSummary> get historySummaries => List.unmodifiable(_historySummaries);
  DateTime? get historyFilterDate => _historyFilterDate;
  bool get isLoading => _isLoading;

  // Selected date statistics
  int get totalTasks => _selectedDateTasks.length;
  int get completedTasks => _selectedDateTasks.where((t) => t.isCompleted).length;
  int get pendingTasks => totalTasks - completedTasks;
  double get completionRate => totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
  int get completionPercentage =>
      totalTasks == 0 ? 0 : ((completedTasks / totalTasks) * 100).round();
  bool get isAllCompleted => totalTasks > 0 && completedTasks == totalTasks;

  // Filtered history summaries
  List<DateTaskSummary> get filteredHistorySummaries {
    if (_historyFilterDate == null) {
      return _historySummaries;
    }
    final target = AppDateUtils.normalize(_historyFilterDate!);
    return _historySummaries
        .where((summary) => AppDateUtils.normalize(summary.date) == target)
        .toList();
  }

  /// Initial load of data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _loadData();

    _isLoading = false;
    notifyListeners();
  }

  /// Changes the currently active date on the Today screen
  Future<void> setSelectedDate(DateTime date) async {
    final normalized = AppDateUtils.normalize(date);
    if (_selectedDate == normalized) return;

    _selectedDate = normalized;
    _selectedDateTasks = await _repository.getTasksByDate(_selectedDate);
    notifyListeners();
  }

  /// Navigates to the next day
  Future<void> goToNextDay() async {
    await setSelectedDate(_selectedDate.add(const Duration(days: 1)));
  }

  /// Navigates to the previous day
  Future<void> goToPreviousDay() async {
    await setSelectedDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  /// Resets to today's date
  Future<void> goToToday() async {
    await setSelectedDate(DateTime.now());
  }

  /// Sets or clears date filter for history tab
  void setHistoryFilterDate(DateTime? date) {
    if (date == null) {
      _historyFilterDate = null;
    } else {
      _historyFilterDate = AppDateUtils.normalize(date);
    }
    notifyListeners();
  }

  /// Adds a task to repository and updates UI
  Future<void> addTask(Task task) async {
    await _repository.addTask(task);
    await _loadData();
    notifyListeners();
  }

  /// Updates an existing task and updates UI
  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);
    await _loadData();
    notifyListeners();
  }

  /// Deletes a task by ID and updates UI
  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
    await _loadData();
    notifyListeners();
  }

  /// Toggles task completion status and updates UI
  Future<void> toggleTask(String taskId) async {
    await _repository.toggleTask(taskId);
    await _loadData();
    notifyListeners();
  }

  /// Loads tasks for selected date and all history summaries
  Future<void> _loadData() async {
    _selectedDateTasks = await _repository.getTasksByDate(_selectedDate);

    final allTasks = await _repository.getAllTasks();
    final Map<String, List<Task>> groupedMap = {};

    for (final task in allTasks) {
      final key = AppDateUtils.toKey(task.date);
      groupedMap.putIfAbsent(key, () => []).add(task);
    }

    final List<DateTaskSummary> summaries = [];
    groupedMap.forEach((key, tasks) {
      final date = AppDateUtils.fromKey(key);
      summaries.add(DateTaskSummary(date: date, tasks: tasks));
    });

    // Sort history by date descending
    summaries.sort((a, b) => b.date.compareTo(a.date));
    _historySummaries = summaries;

    // Automatically synchronize daily 9 PM reminder based on today's tasks
    try {
      await NotificationService().syncDailyReminder(_repository);
    } catch (e) {
      debugPrint('Error syncing reminder from TaskController: $e');
    }
  }
}
