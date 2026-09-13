import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../controllers/task_controller.dart';
import 'widgets/history_date_card.dart';

class HistoryScreen extends StatelessWidget {
  final ValueChanged<DateTime>? onNavigateToDate;

  const HistoryScreen({
    super.key,
    this.onNavigateToDate,
  });

  Future<void> _pickDate(BuildContext context, TaskController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.historyFilterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      controller.setHistoryFilterDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final filteredSummaries = taskController.filteredHistorySummaries;
    final filterDate = taskController.historyFilterDate;
    final theme = Theme.of(context);

    return Scaffold(
      body: taskController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => taskController.initialize(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'History',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (filterDate != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        AppDateUtils.formatMedium(filterDate),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () => taskController.setHistoryFilterDate(null),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => _pickDate(context, taskController),
                            icon: const Icon(Icons.calendar_today_outlined, size: 20),
                            tooltip: 'Filter by Date',
                            style: IconButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (filteredSummaries.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 36,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                filterDate != null
                                    ? 'No records for this date'
                                    : 'No routine history yet',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.titleMedium?.color,
                                ),
                              ),
                              if (filterDate != null) ...[
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: () => taskController.setHistoryFilterDate(null),
                                  child: const Text('Show All History', style: TextStyle(fontSize: 13)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final summary = filteredSummaries[index];
                            return HistoryDateCard(
                              key: ValueKey(summary.date.toIso8601String()),
                              summary: summary,
                              onOpenInToday: onNavigateToDate != null
                                  ? () => onNavigateToDate!(summary.date)
                                  : null,
                            );
                          },
                          childCount: filteredSummaries.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
