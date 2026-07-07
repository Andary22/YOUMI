/// Decodes a habit recurrence bitmask (bit 0 = Monday ... bit 6 = Sunday)
/// into a short display string. A mask of 0 or a full week is treated as
/// "Daily" since that's how habits with no explicit schedule behave.
String formatRecurrenceMask(int mask) {
  const List<String> dayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  if (mask <= 0 || mask >= 0x7F) {
    return 'Daily';
  }
  final List<String> selected = [];
  for (int i = 0; i < dayLabels.length; i++) {
    if ((mask & (1 << i)) != 0) {
      selected.add(dayLabels[i]);
    }
  }
  if (selected.isEmpty) {
    return 'Daily';
  }
  if (selected.length == 7) {
    return 'Daily';
  }
  return selected.join(', ');
}

Duration parseInterval(dynamic value) {
  if (value is Duration) {
    return value;
  }
  if (value is int) {
    return Duration(seconds: value);
  }
  if (value is String) {
    return _parseIntervalString(value);
  }
  throw FormatException('Invalid interval value: $value');
}

String formatInterval(Duration value) {
  final bool isNegative = value.isNegative;
  final int absSeconds = value.inSeconds.abs();
  final int hours = absSeconds ~/ 3600;
  final int minutes = (absSeconds % 3600) ~/ 60;
  final int seconds = absSeconds % 60;
  final int micros = value.inMicroseconds.remainder(1000000).abs();

  String sign = '';
  if (isNegative) {
    sign = '-';
  }

  final String base =
      '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

  if (micros == 0) {
    return base;
  }

  String fraction = micros.toString().padLeft(6, '0');
  fraction = fraction.replaceFirst(RegExp(r'0+$'), '');
  return '$base.$fraction';
}

Duration _parseIntervalString(String value) {
  final String trimmed = value.trim();
  final RegExp dayPattern = RegExp(r'^(\d+)\s+day[s]?\s+(.+)$');
  final RegExpMatch? dayMatch = dayPattern.firstMatch(trimmed);

  int days = 0;
  String timePart = trimmed;
  if (dayMatch != null) {
    days = int.parse(dayMatch.group(1)!);
    timePart = dayMatch.group(2)!;
  }

  final RegExp timePattern = RegExp(
    r'^(\d{1,2}):(\d{2}):(\d{2})(?:\.(\d{1,6}))?$',
  );
  final RegExpMatch? timeMatch = timePattern.firstMatch(timePart);
  if (timeMatch == null) {
    throw FormatException('Invalid interval format: $value');
  }

  final int hours = int.parse(timeMatch.group(1)!);
  final int minutes = int.parse(timeMatch.group(2)!);
  final int seconds = int.parse(timeMatch.group(3)!);
  final String? fraction = timeMatch.group(4);

  int micros = 0;
  if (fraction != null) {
    micros = int.parse(fraction.padRight(6, '0'));
  }

  return Duration(
    hours: hours + (days * 24),
    minutes: minutes,
    seconds: seconds,
    microseconds: micros,
  );
}