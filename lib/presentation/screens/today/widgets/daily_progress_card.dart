import 'package:flutter/material.dart';

class DailyProgressCard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionRate;
  final int completionPercentage;
  final bool isAllCompleted;
  final bool isToday;

  const DailyProgressCard({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionRate,
    required this.completionPercentage,
    required this.isAllCompleted,
    this.isToday = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isToday ? "Today's Progress" : 'Daily Progress',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '$completionPercentage%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isAllCompleted && totalTasks > 0
                      ? const Color(0xFF10B981)
                      : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Simple readable count text: "3 of 6 completed" or "3 completed · 3 remaining"
          Text(
            totalTasks == 0
                ? 'No tasks scheduled'
                : '$completedTasks completed · $pendingTasks remaining',
            style: TextStyle(
              fontSize: 13,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          // Thin modern progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              tween: Tween<double>(
                begin: 0.0,
                end: completionRate.clamp(0.0, 1.0),
              ),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 5,
                  backgroundColor: theme.dividerColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAllCompleted && totalTasks > 0
                        ? const Color(0xFF10B981)
                        : theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),

          if (isAllCompleted && totalTasks > 0) ...[
            const SizedBox(height: 8),
            const Text(
              '🎉 All tasks completed for today!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
