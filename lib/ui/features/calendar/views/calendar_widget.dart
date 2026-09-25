import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quest_kalender/ui/core/themes/app_theme.dart';
import 'package:quest_kalender/ui/features/quests/view_models/quest_view_model.dart';

class CalendarWidget extends StatelessWidget {
  final QuestViewModel viewModel;

  const CalendarWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLighter, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Baris Navigasi Bulan & Mode Tampilan
          _buildHeader(context),
          const SizedBox(height: 10),

          // Tampilan Berdasarkan Mode dengan transisi halus
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey<String>(viewModel.calendarViewMode),
              child: viewModel.calendarViewMode == 'month'
                  ? _buildMonthGrid(context)
                  : viewModel.calendarViewMode == 'week'
                  ? _buildWeekStrip(context)
                  : _buildDayHeader(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                        // Bulan & Tahun tampil lengkap penuh tanpa "..."
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              monthYearStr,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Tombol Kembali ke Hari Ini
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: AppTheme.primaryGold.withAlpha(25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => viewModel.selectDate(DateTime.now()),
                          child: const Text(
                            'Hari Ini',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Prev & Next Bulan
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: viewModel.previousMonth,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: viewModel.nextMonth,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Pilihan Mode (Bulan, Minggu, Hari) Full Width di Portrait
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLighter,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModeButton('month', 'Bulan', expand: true),
                    ),
                    Expanded(
                      child: _buildModeButton('week', 'Minggu', expand: true),
                    ),
                    Expanded(
                      child: _buildModeButton('day', 'Hari', expand: true),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Tampilan Landscape / Layar Lebar
        return Row(
          children: [
            // Bulan & Tahun
            Text(
              monthYearStr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),

            // Tombol Kembali ke Hari Ini
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => viewModel.selectDate(DateTime.now()),
              child: const Text(
                'Hari Ini',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            // Tombol Prev & Next Bulan
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              visualDensity: VisualDensity.compact,
              onPressed: viewModel.previousMonth,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              visualDensity: VisualDensity.compact,
              onPressed: viewModel.nextMonth,
            ),

            const SizedBox(width: 4),

            // Pilihan Mode (Bulan, Minggu, Hari)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceLighter,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  _buildModeButton('month', 'Bulan'),
                  _buildModeButton('week', 'Minggu'),
                  _buildModeButton('day', 'Hari'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeButton(String mode, String label, {bool expand = false}) {
    final isSelected = viewModel.calendarViewMode == mode;
    return InkWell(
      onTap: () => viewModel.setCalendarViewMode(mode),
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: expand ? Alignment.center : null,
        padding: EdgeInsets.symmetric(
          horizontal: expand ? 4 : 10,
          vertical: expand ? 6 : 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthGrid(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final curMonth = viewModel.currentMonth;

    // Hari pertama bulan ini
    final firstDayOfMonth = DateTime(curMonth.year, curMonth.month, 1);
    // Senin = 1, Minggu = 7. Sesuaikan agar Senin = kolom 0
    final int startingWeekday = firstDayOfMonth.weekday; // 1 (Mon) to 7 (Sun)
    final int leadingEmptyDays = startingWeekday - 1;

    // Total hari dalam bulan ini
    final daysInMonth = DateTime(curMonth.year, curMonth.month + 1, 0).day;

    final List<Widget> dayWidgets = [];

    // Header Nama Hari (Sen s/d Min)
    const weekDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final headerRow = Row(
      children: weekDays
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );

    // Padding tanggal bulan sebelumnya
    final prevMonthLastDay = DateTime(curMonth.year, curMonth.month, 0).day;
    for (int i = 0; i < leadingEmptyDays; i++) {
      final dayNum = prevMonthLastDay - leadingEmptyDays + 1 + i;
      dayWidgets.add(
        Center(
          child: Text(
            '$dayNum',
            style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(40)),
          ),
        ),
      );
    }

    // Tanggal bulan berjalan
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
        InkWell(
          onTap: () => viewModel.selectDate(date),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryGold
                  : (isToday ? AppTheme.surfaceLighter : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isSelected
                  ? Border.all(color: AppTheme.primaryGold, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.black
                        : (isToday ? AppTheme.primaryGold : Colors.white),
                  ),
                ),
                // Dot indikator Quest
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
                              ? Colors.black87
                              : (q.isCompleted
                                    ? AppTheme.textMuted
                                    : q.rank.color),
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

    // Gridview builder untuk kalender bulanan dengan transisi cross-fade
    return Column(
      children: [
        headerRow,
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = viewModel.selectedDate;

    // Hitung awal minggu (Senin)
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
          child: InkWell(
            onTap: () => viewModel.selectDate(date),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGold
                    : (isToday ? AppTheme.surfaceLighter : Colors.transparent),
                borderRadius: BorderRadius.circular(10),
                border: isToday && !isSelected
                    ? Border.all(color: AppTheme.primaryGold, width: 1.5)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black87 : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.black
                          : (isToday ? AppTheme.primaryGold : Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (quests.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.black87
                            : AppTheme.surfaceLighter,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${quests.length}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppTheme.primaryGold
                              : Colors.white70,
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
    final selected = viewModel.selectedDate;
    final formatted = DateFormat('EEEE, dd MMMM yyyy').format(selected);
    final quests = viewModel.getQuestsForDate(selected);
    final completedCount = quests.where((q) => q.isCompleted).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLighter.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_note, color: AppTheme.neonCyan, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              formatted,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$completedCount/${quests.length} Quest Selesai',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
