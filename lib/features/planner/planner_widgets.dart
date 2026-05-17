part of 'planner.dart';

extension _PlannerWidgets on _PlannerViewState {
  Widget _buildScheduleTab(ThemeData theme, ExecutionProvider execution) {
    final selected = _selectedDay ?? _focusedDay;
    final eventsForSelected = execution.eventsForDate(selected);
    List<Widget> children = [];

    children.add(_buildCalendar(theme, execution));
    children.add(const SizedBox(height: 16));
    children.add(
      Row(
        children: [
          Text(_formatFullDate(selected), style: theme.textTheme.titleMedium),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              _openQuickAddPage(selected);
            },
            icon: const Icon(Icons.add),
            label: const Text('Quick Add'),
          ),
        ],
      ),
    );
    children.add(const SizedBox(height: 8));
    if (eventsForSelected.isEmpty) {
      children.add(
        Text('No scheduled items.', style: theme.textTheme.bodyMedium),
      );
    } else {
      for (int i = 0; i < eventsForSelected.length; i++) {
        children.add(_buildEventTile(theme, eventsForSelected[i]));
      }
    }

    return ListView(padding: const EdgeInsets.all(16), children: children);
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
            child: Text(weekDays[i], style: theme.textTheme.bodySmall),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.onSurface,
              ),
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
              icon: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface,
              ),
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDayLabels,
        ),
        const SizedBox(height: 8),
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
    final textColor = inMonth
        ? theme.textTheme.bodyMedium?.color ?? Colors.black
        : theme.disabledColor;

    BoxDecoration? decoration;
    if (isSelected) {
      decoration = BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary),
        shape: BoxShape.circle,
      );
    }

    List<Widget> contents = [];
    contents.add(
      Container(
        width: 36,
        height: 36,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isSelected ? theme.colorScheme.onPrimary : textColor,
          ),
        ),
      ),
    );
    contents.add(const SizedBox(height: 6));
    if (events.isNotEmpty) {
      contents.add(
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        _selectCalendarDay(day);
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        child: Column(mainAxisSize: MainAxisSize.min, children: contents),
      ),
    );
  }

  Widget _buildEventTile(ThemeData theme, ActivityInstance item) {
    final blueprint = Provider.of<BlueprintProvider>(context, listen: false);
    final isHabit = item.habitId != null;
    final title = _resolveTitle(item, blueprint);
    final label = _resolveLabel(item, blueprint);
    String timeText = 'Habit';
    if (!isHabit) {
      timeText = _formatTime(
        item.scheduledDate,
        MaterialLocalizations.of(context),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(timeText, style: theme.textTheme.bodySmall),
          InkWell(
            onTap: () {
              _editItemLabel(item);
            },
            child: Text(
              '# ${_labelText(label)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: isHabit
                ? null
                : () {
                    _editItemTime(item);
                  },
          ),
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            onPressed: () {
              _editItemNote(item);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            onPressed: () {
              Provider.of<ExecutionProvider>(
                context,
                listen: false,
              ).removeItem(item.id);
              _showAddFeedback(context, 'Deleted $title');
            },
          ),
        ],
      ),
    );
  }
}
