import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/task.dart';
import '../../controllers/task_controller.dart';
import '../../widgets/confirmation_dialog.dart';
import '../task_form/task_form_sheet.dart';
import 'widgets/daily_progress_card.dart';
import 'widgets/date_selector_bar.dart';
import 'widgets/empty_tasks_view.dart';
import 'widgets/task_item_tile.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  Future<void> _handleAddTask(BuildContext context, DateTime selectedDate) async {
    final taskController = context.read<TaskController>();
    final newTask = await TaskFormSheet.show(
      context,
      initialDate: selectedDate,
    );
    if (newTask != null) {
      await taskController.addTask(newTask);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${newTask.title}"'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleEditTask(BuildContext context, Task task) async {
    final taskController = context.read<TaskController>();
    final updated = await TaskFormSheet.show(
      context,
      taskToEdit: task,
      initialDate: task.date,
    );
    if (updated != null) {
      await taskController.updateTask(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated "${updated.title}"'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteTask(BuildContext context, Task task) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete task?',
      content: 'Are you sure you want to delete "${task.title}"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (confirmed && context.mounted) {
      final taskController = context.read<TaskController>();
      await taskController.deleteTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final selectedDate = taskController.selectedDate;
    final tasks = taskController.selectedDateTasks;
    final isToday = AppDateUtils.isToday(selectedDate);
    final theme = Theme.of(context);

    return Scaffold(
      body: taskController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => taskController.initialize(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Compact Date Selector
                        DateSelectorBar(
                          selectedDate: selectedDate,
                          onPrevious: () => taskController.goToPreviousDay(),
                          onNext: () => taskController.goToNextDay(),
                          onSelectDate: (d) => taskController.setSelectedDate(d),
                          onJumpToToday: () => taskController.goToToday(),
                        ),

                        // Lightweight Progress Section
                        DailyProgressCard(
                          totalTasks: taskController.totalTasks,
                          completedTasks: taskController.completedTasks,
                          pendingTasks: taskController.pendingTasks,
                          completionRate: taskController.completionRate,
                          completionPercentage:
                              taskController.completionPercentage,
                          isAllCompleted: taskController.isAllCompleted,
                          isToday: isToday,
                        ),

                        // Section Header: "Today's Tasks    6"
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isToday ? "Today's Tasks" : 'Routine Tasks',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              if (tasks.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${tasks.length}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tasks List or Empty State
                  if (tasks.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyTasksView(
                        onAddTask: () => _handleAddTask(context, selectedDate),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = tasks[index];
                            return TaskItemTile(
                              key: ValueKey(task.id),
                              task: task,
                              onToggle: (_) =>
                                  taskController.toggleTask(task.id),
                              onEdit: () => _handleEditTask(context, task),
                              onDelete: () => _handleDeleteTask(context, task),
                            );
                          },
                          childCount: tasks.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleAddTask(context, selectedDate),
        tooltip: 'Add Task',
        mini: false,
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }
}
