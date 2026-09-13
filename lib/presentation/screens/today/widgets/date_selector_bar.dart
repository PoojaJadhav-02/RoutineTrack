import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';

class DateSelectorBar extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onJumpToToday;

  const DateSelectorBar({
    super.key,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectDate,
    required this.onJumpToToday,
  });

  Future<void> _openDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      onSelectDate(AppDateUtils.normalize(picked));
    }
  }

  String _formatDisplayDate() {
    if (AppDateUtils.isToday(selectedDate)) {
      return 'Today • ${AppDateUtils.formatShort(selectedDate)}';
    } else if (AppDateUtils.isYesterday(selectedDate)) {
      return 'Yesterday • ${AppDateUtils.formatShort(selectedDate)}';
    } else if (AppDateUtils.isTomorrow(selectedDate)) {
      return 'Tomorrow • ${AppDateUtils.formatShort(selectedDate)}';
    }
    return AppDateUtils.formatFull(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = AppDateUtils.isToday(selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous day button
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded, size: 24),
            tooltip: 'Previous Day',
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(8),
            ),
          ),

          // Date center display with calendar trigger
          InkWell(
            onTap: () => _openDatePicker(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDisplayDate(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: isToday
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),

          // Next day button
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded, size: 24),
            tooltip: 'Next Day',
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
}
