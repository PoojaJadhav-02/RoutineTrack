import '../entities/task.dart';

abstract class TaskRepository {
  /// Retrieves all tasks for a specific date (normalized yyyy-MM-dd)
  Future<List<Task>> getTasksByDate(DateTime date);

  /// Retrieves all tasks stored across all dates
  Future<List<Task>> getAllTasks();

  /// Adds a new task to persistent storage
  Future<void> addTask(Task task);

  /// Updates an existing task
  Future<void> updateTask(Task task);

  /// Deletes a task by its unique ID
  Future<void> deleteTask(String taskId);

  /// Toggles the completion status of a task
  Future<void> toggleTask(String taskId);

  /// Retrieves a distinct list of dates that have tasks, sorted in descending order
  Future<List<DateTime>> getDatesWithTasks();

  /// Clears all tasks (used for resets or tests)
  Future<void> clearAllTasks();
}
