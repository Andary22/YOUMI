part of 'planner.dart';

extension _PlannerWidgets on _PlannerViewState {
  Widget _buildScheduleTab(ThemeData theme, ExecutionProvider execution) {
    DateTime selected = _focusedDay;
    if (_selectedDay != null) {
      selected = _selectedDay!;
    }
    final eventsForSelected = execution.eventsForDate(selected);
    eventsForSelected.sort(
      (a, b) => a.scheduledDate.compareTo(b.scheduledDate),
    );
    List<Widget> children = [];

    children.add(_buildCalendarCard(theme, execution));
    children.add(const SizedBox(height: 20));
    children.add(
      Row(
        children: [
          Expanded(
            child: Text(
              _formatFullDate(selected),
              style: theme.textTheme.titleMedium,
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () {
              _openQuickAddPage(selected);
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Quick Add'),
          ),
        ],
      ),
    );
    children.add(const SizedBox(height: 12));
    if (eventsForSelected.isEmpty) {
      children.add(
        const EmptyState(
          icon: Icons.event_available_outlined,
          title: 'Nothing scheduled',
          message: 'Tap Quick Add to schedule a task or habit for this day.',
        ),
      );
    } else {
      for (int i = 0; i < eventsForSelected.length; i++) {
        children.add(_buildEventTile(theme, eventsForSelected[i]));
      }
    }

    return RuledPage(
      child: ListView(padding: const EdgeInsets.all(16), children: children),
    );
  }

  Widget _buildCalendarCard(ThemeData theme, ExecutionProvider execution) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
        child: _buildCalendar(theme, execution),
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme, ExecutionProvider execution) {
    final days = _calendarDays(_focusedDay);
    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    List<Widget> weekDayLabels = [];
    List<Widget> weekRows = [];

    for (int i = 0; i < weekDays.length; i++) {
      weekDayLabels.add(
        Expanded(
          child: Center(
            child: Text(
              weekDays[i],
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    for (int week = 0; week < 6; week++) {
      List<Widget> cells = [];
      for (int weekday = 0; weekday < 7; weekday++) {
        cells.add(
          Expanded(
            child: _buildDayCell(theme, execution, days[week * 7 + weekday]),
          ),
        );
      }
      weekRows.add(Row(children: cells));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  _goToPreviousMonth();
                  execution.fetchMonthData(
                    _focusedDay,
                    monthsBefore: _monthsBefore,
                    monthsAfter: _monthsAfter,
                  );
                },
              ),
              Text(
                '${_monthName(_focusedDay.month)} ${_focusedDay.year}',
                style: theme.textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  _goToNextMonth();
                  execution.fetchMonthData(
                    _focusedDay,
                    monthsBefore: _monthsBefore,
                    monthsAfter: _monthsAfter,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDayLabels,
        ),
        const SizedBox(height: 4),
        Column(children: weekRows),
      ],
    );
  }

  List<DateTime> _calendarDays(DateTime focusedDay) {
    final firstOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final startOffset = firstOfMonth.weekday % 7;
    final startDay = firstOfMonth.subtract(Duration(days: startOffset));
    List<DateTime> days = [];
    for (int i = 0; i < 42; i++) {
      days.add(startDay.add(Duration(days: i)));
    }
    return days;
  }

  Widget _buildDayCell(
    ThemeData theme,
    ExecutionProvider execution,
    DateTime day,
  ) {
    final isSelected = _selectedDay != null && _isSameDay(day, _selectedDay!);
    final isToday = _isSameDay(day, DateTime.now());
    final inMonth = day.month == _focusedDay.month;
    final events = execution.eventsForDate(day);

    Color textColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    if (inMonth) {
      textColor = theme.colorScheme.onSurface;
    }
    if (isSelected) {
      textColor = theme.colorScheme.onPrimary;
    } else if (isToday) {
      textColor = theme.colorScheme.primary;
    }

    BoxDecoration? decoration;
    if (isSelected) {
      decoration = BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary, width: 1.4),
        shape: BoxShape.circle,
      );
    }

    return GestureDetector(
      onTap: () {
        _selectCalendarDay(day);
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: decoration,
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 5,
              child: events.isEmpty
                  ? null
                  : Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTile(ThemeData theme, ActivityInstance item) {
    final blueprint = Provider.of<BlueprintProvider>(context, listen: false);
    final isHabit = item.habitId != null;
    final title = _resolveTitle(item, blueprint);
    final label = _resolveLabel(item, blueprint);
    String timeText = 'Habit · repeats';
    if (!isHabit) {
      timeText = _formatTime(
        item.scheduledDate,
        MaterialLocalizations.of(context),
      );
    }

    VoidCallback? scheduleAction;
    if (!isHabit) {
      scheduleAction = () {
        _editItemTime(item);
      };
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(timeText, style: theme.textTheme.bodySmall),
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                _editItemLabel(item);
                              },
                              child: TabChip(label: label, dense: true),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.schedule_outlined),
                  tooltip: 'Change time',
                  onPressed: scheduleAction,
                ),
                IconButton(
                  icon: const Icon(Icons.note_alt_outlined),
                  tooltip: 'Note',
                  onPressed: () {
                    _editItemNote(item);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  tooltip: 'Delete',
                  onPressed: () {
                    _deleteItem(item, title);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}