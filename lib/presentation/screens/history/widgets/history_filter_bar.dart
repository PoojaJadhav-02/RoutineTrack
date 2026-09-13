import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';

class HistoryFilterBar extends StatelessWidget {
  final DateTime? filterDate;
  final ValueChanged<DateTime?> onSelectFilterDate;

  const HistoryFilterBar({
    super.key,
    required this.filterDate,
    required this.onSelectFilterDate,
  });

  Future<void> _pickFilterDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      onSelectFilterDate(AppDateUtils.normalize(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilter = filterDate != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 20,
            color: hasFilter
                ? theme.colorScheme.primary
                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: hasFilter
                ? Row(
                    children: [
                      Text(
                        'Showing: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          AppDateUtils.formatMedium(filterDate!),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'All Recorded Routine Days',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.8),
                    ),
                  ),
          ),
          if (hasFilter)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              tooltip: 'Clear filter',
              style: IconButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(4),
              ),
              onPressed: () => onSelectFilterDate(null),
            ),
          OutlinedButton.icon(
            onPressed: () => _pickFilterDate(context),
            icon: const Icon(Icons.calendar_today_rounded, size: 14),
            label: Text(hasFilter ? 'Change' : 'Pick Date'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
