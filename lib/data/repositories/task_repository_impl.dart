import '../../core/utils/date_utils.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../local/task_local_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _localDataSource;

  TaskRepositoryImpl({required TaskLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final allTasks = await _localDataSource.getSavedTasks();
    final normalizedDate = AppDateUtils.normalize(date);

    final filtered = allTasks
        .where((t) => AppDateUtils.normalize(t.date) == normalizedDate)
        .map((t) => t.toEntity())
        .toList();

    _sortTasks(filtered);
    return filtered;
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final allTasks = await _localDataSource.getSavedTasks();
    final entities = allTasks.map((t) => t.toEntity()).toList();
    _sortTasks(entities);
    return entities;
  }

  @override
  Future<void> addTask(Task task) async {
    final allTasks = await _localDataSource.getSavedTasks();
    final model = TaskModel.fromEntity(task);
    allTasks.add(model);
    await _localDataSource.saveTasks(allTasks);
  }

  @override
  Future<void> updateTask(Task task) async {
    final allTasks = await _localDataSource.getSavedTasks();
    final index = allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      allTasks[index] = TaskModel.fromEntity(task);
      await _localDataSource.saveTasks(allTasks);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final allTasks = await _localDataSource.getSavedTasks();
    allTasks.removeWhere((t) => t.id == taskId);
    await _localDataSource.saveTasks(allTasks);
  }

  @override
  Future<void> toggleTask(String taskId) async {
    final allTasks = await _localDataSource.getSavedTasks();
    final index = allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final current = allTasks[index];
      final newCompleted = !current.isCompleted;
      final updated = current.copyWith(
        isCompleted: newCompleted,
        completedAt: newCompleted ? DateTime.now() : null,
        clearCompletedAt: !newCompleted,
      );
      allTasks[index] = TaskModel.fromEntity(updated);
      await _localDataSource.saveTasks(allTasks);
    }
  }

  @override
  Future<List<DateTime>> getDatesWithTasks() async {
    final allTasks = await _localDataSource.getSavedTasks();
    final dateSet = <DateTime>{};
    for (final task in allTasks) {
      dateSet.add(AppDateUtils.normalize(task.date));
    }
    final sortedDates = dateSet.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending order
    return sortedDates;
  }

  @override
  Future<void> clearAllTasks() async {
    await _localDataSource.clearTasks();
  }

  /// Sorts tasks:
  /// 1. Timed tasks first, ordered chronologically.
  /// 2. Untimed tasks after timed tasks.
  /// 3. In case of tie, ordered by createdAt.
  void _sortTasks(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.time != null && b.time != null) {
        final timeComparison = AppTimeUtils.compareTimeOfDay(a.time!, b.time!);
        if (timeComparison != 0) return timeComparison;
      } else if (a.time != null && b.time == null) {
        return -1; // a comes first
      } else if (a.time == null && b.time != null) {
        return 1; // b comes first
      }
      return a.createdAt.compareTo(b.createdAt);
    });
  }
}
