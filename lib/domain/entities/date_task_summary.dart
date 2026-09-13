import 'task.dart';

class DateTaskSummary {
  final DateTime date;
  final List<Task> tasks;

  const DateTaskSummary({
    required this.date,
    required this.tasks,
  });

  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((t) => t.isCompleted).length;
  int get pendingTasks => totalTasks - completedTasks;

  double get completionRate =>
      totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  int get completionPercentage =>
      totalTasks == 0 ? 0 : ((completedTasks / totalTasks) * 100).round();

  bool get isAllCompleted => totalTasks > 0 && completedTasks == totalTasks;
}
