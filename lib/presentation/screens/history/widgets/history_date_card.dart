import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../domain/entities/date_task_summary.dart';
import '../../../../domain/entities/task.dart';

class HistoryDateCard extends StatelessWidget {
  final DateTaskSummary summary;
  final VoidCallback? onOpenInToday;

  const HistoryDateCard({
    super.key,
    required this.summary,
    this.onOpenInToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final isToday = AppDateUtils.isToday(summary.date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header & Progress %
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isToday
                          ? 'Today • ${AppDateUtils.formatMedium(summary.date)}'
                          : AppDateUtils.formatMedium(summary.date),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? theme.colorScheme.primary
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${summary.completionPercentage}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: summary.isAllCompleted
                        ? const Color(0xFF10B981)
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),

            // Progress text: "4 of 6 completed"
            Text(
              '${summary.completedTasks} of ${summary.totalTasks} completed',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Thin progress line
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: summary.completionRate,
                minHeight: 4,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  summary.isAllCompleted
                      ? const Color(0xFF10B981)
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tasks list
            Column(
              children: summary.tasks.map((task) {
                return _buildTaskRow(context, task);
              }).toList(),
            ),

            if (onOpenInToday != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: onOpenInToday,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Open in Today',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskRow(BuildContext context, Task task) {
    final theme = Theme.of(context);
    final isDone = task.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 15,
            color: isDone
                ? const Color(0xFF10B981)
                : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isDone ? FontWeight.w400 : FontWeight.w500,
                decoration:
                    isDone ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.35),
                color: isDone
                    ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4)
                    : theme.textTheme.bodyLarge?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (task.time != null) ...[
            const SizedBox(width: 6),
            Text(
              AppTimeUtils.formatTimeOfDay(context, task.time!),
              style: TextStyle(
                fontSize: 11,
                color: theme.textTheme.bodySmall?.color
                    ?.withValues(alpha: isDone ? 0.35 : 0.55),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
