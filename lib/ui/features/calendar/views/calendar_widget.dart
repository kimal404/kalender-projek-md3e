import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quest_kalender/ui/core/widgets/animated_tap_menu.dart';
import 'package:quest_kalender/ui/features/quests/view_models/quest_view_model.dart';

class CalendarWidget extends StatelessWidget {
  final QuestViewModel viewModel;

  const CalendarWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: KeyedSubtree(
                  key: ValueKey<String>(viewModel.calendarViewMode),
                  child: viewModel.calendarViewMode == 'month'
                      ? _buildMonthGrid(context)
                      : viewModel.calendarViewMode == 'week'
                          ? _buildWeekStrip(context)
                          : _buildDayHeader(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final monthYearStr = DateFormat('MMMM yyyy').format(viewModel.currentMonth);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 460;

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              monthYearStr,
                              maxLines: 1,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => viewModel.selectDate(DateTime.now()),
                          child: const Text(
                            'Hari Ini',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    visualDensity: VisualDensity.compact,
                    onPressed: viewModel.previousMonth,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 22),
                    visualDensity: VisualDensity.compact,
                    onPressed: viewModel.nextMonth,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _CalendarModeSlidingSelector(
                currentMode: viewModel.calendarViewMode,
                onModeChanged: viewModel.setCalendarViewMode,
              ),
            ],
          );
        }

        return Row(
          children: [
            Text(
              monthYearStr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => viewModel.selectDate(DateTime.now()),
              child: const Text('Hari Ini', style: TextStyle(fontSize: 12)),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 22),
              visualDensity: VisualDensity.compact,
              onPressed: viewModel.previousMonth,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 22),
              visualDensity: VisualDensity.compact,
              onPressed: viewModel.nextMonth,
            ),
            const SizedBox(width: 6),
            _CalendarModeSlidingSelector(
              currentMode: viewModel.calendarViewMode,
              onModeChanged: viewModel.setCalendarViewMode,
              width: 220,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthGrid(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final curMonth = viewModel.currentMonth;

    final firstDayOfMonth = DateTime(curMonth.year, curMonth.month, 1);
    final int startingWeekday = firstDayOfMonth.weekday;
    final int leadingEmptyDays = startingWeekday - 1;
    final daysInMonth = DateTime(curMonth.year, curMonth.month + 1, 0).day;

    final List<Widget> dayWidgets = [];

    const weekDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final headerRow = Row(
      children: weekDays
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );

    final prevMonthLastDay = DateTime(curMonth.year, curMonth.month, 0).day;
    for (int i = 0; i < leadingEmptyDays; i++) {
      final dayNum = prevMonthLastDay - leadingEmptyDays + 1 + i;
      dayWidgets.add(
        Center(
          child: Text(
            '$dayNum',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
        ),
      );
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(curMonth.year, curMonth.month, day);
      final isSelected =
          date.year == viewModel.selectedDate.year &&
          date.month == viewModel.selectedDate.month &&
          date.day == viewModel.selectedDate.day;
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

      final questsOnDay = viewModel.getQuestsForDate(date);

      dayWidgets.add(
        AnimatedPressScale(
          isSelected: isSelected,
          selectedScale: 1.04,
          pressedScale: 0.92,
          onTap: () => viewModel.selectDate(date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : (isToday ? colorScheme.primaryContainer.withValues(alpha: 0.4) : Colors.transparent),
              borderRadius: BorderRadius.circular(14),
              border: isToday && !isSelected
                  ? Border.all(color: colorScheme.primary, width: 1.2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : (isToday ? colorScheme.primary : colorScheme.onSurface),
                  ),
                ),
                const SizedBox(height: 2),
                if (questsOnDay.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: questsOnDay.take(3).map((q) {
                      return Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : (q.isCompleted
                                  ? colorScheme.outlineVariant
                                  : colorScheme.primary),
                        ),
                      );
                    }).toList(),
                  )
                else
                  const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        headerRow,
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: GridView.count(
            key: ValueKey<String>('${curMonth.year}-${curMonth.month}'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            childAspectRatio: 1.15,
            children: dayWidgets,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekStrip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = viewModel.selectedDate;

    final startOfWeek = selected.subtract(Duration(days: selected.weekday - 1));

    return Row(
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isSelected =
            date.year == selected.year &&
            date.month == selected.month &&
            date.day == selected.day;
        final isToday =
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final quests = viewModel.getQuestsForDate(date);
        final dayName = DateFormat('E').format(date);

        return Expanded(
          child: AnimatedPressScale(
            isSelected: isSelected,
            selectedScale: 1.03,
            pressedScale: 0.92,
            onTap: () => viewModel.selectDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : (isToday ? colorScheme.primaryContainer.withValues(alpha: 0.4) : Colors.transparent),
                borderRadius: BorderRadius.circular(14),
                border: isToday && !isSelected
                    ? Border.all(color: colorScheme.primary, width: 1.2)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.onPrimary.withValues(alpha: 0.8)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : (isToday ? colorScheme.primary : colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (quests.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.onPrimary.withValues(alpha: 0.2)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${quests.length}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = viewModel.selectedDate;
    final formatted = DateFormat('EEEE, dd MMMM yyyy').format(selected);
    final quests = viewModel.getQuestsForDate(selected);
    final completedCount = quests.where((q) => q.isCompleted).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded, color: colorScheme.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              formatted,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$completedCount/${quests.length} Selesai',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarModeSlidingSelector extends StatelessWidget {
  final String currentMode;
  final ValueChanged<String> onModeChanged;
  final double? width;

  const _CalendarModeSlidingSelector({
    required this.currentMode,
    required this.onModeChanged,
    this.width,
  });

  int get _selectedIndex {
    switch (currentMode) {
      case 'week':
        return 1;
      case 'day':
        return 2;
      case 'month':
      default:
        return 0;
    }
  }

  double get _alignmentX {
    switch (_selectedIndex) {
      case 1:
        return 0.0;
      case 2:
        return 1.0;
      case 0:
      default:
        return -1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selector = Container(
      height: 38,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3.0),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(_alignmentX, 0.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 1.0 / 3.0,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _buildItem(context, 'month', 'Bulan', 0)),
              Expanded(child: _buildItem(context, 'week', 'Minggu', 1)),
              Expanded(child: _buildItem(context, 'day', 'Hari', 2)),
            ],
          ),
        ],
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: selector);
    }
    return selector;
  }

  Widget _buildItem(BuildContext context, String mode, String label, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedIndex == index;

    return AnimatedPressScale(
      pressedScale: 0.94,
      isSelected: false,
      onTap: () => onModeChanged(mode),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
