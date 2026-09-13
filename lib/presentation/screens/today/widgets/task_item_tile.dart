import 'package:flutter/material.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../domain/entities/task.dart';

class TaskItemTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItemTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3.5),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onToggle(!isCompleted),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 4, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accessible Checkbox Touch Area (at least 44x44)
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Checkbox(
                      value: isCompleted,
                      onChanged: onToggle,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // Center: Title, Description, and Time
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isCompleted
                                ? FontWeight.w400
                                : FontWeight.w500,
                            letterSpacing: -0.2,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.4),
                            color: isCompleted
                                ? theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.4)
                                : theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        if (task.description != null &&
                            task.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            task.description!.trim(),
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: isCompleted ? 0.35 : 0.65),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (task.time != null) ...[
                          const SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: isCompleted ? 0.35 : 0.55),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppTimeUtils.formatTimeOfDay(
                                  context,
                                  task.time!,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(
                                          alpha: isCompleted ? 0.35 : 0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Right: Overflow Menu ⋮ (keeps the task row clean)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  ),
                  tooltip: 'Options',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (action) {
                    if (action == 'edit') {
                      onEdit();
                    } else if (action == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      height: 38,
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16),
                          SizedBox(width: 10),
                          Text('Edit', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      height: 38,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
