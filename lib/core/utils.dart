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
  final isNegative = value.isNegative;
  final absSeconds = value.inSeconds.abs();
  final hours = absSeconds ~/ 3600;
  final minutes = (absSeconds % 3600) ~/ 60;
  final seconds = absSeconds % 60;
  final micros = value.inMicroseconds.remainder(1000000).abs();

  final sign = isNegative ? '-' : '';
  final base =
      '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

  if (micros == 0) {
    return base;
  }

  final fraction = micros
      .toString()
      .padLeft(6, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return '$base.$fraction';
}

Duration _parseIntervalString(String value) {
  final trimmed = value.trim();
  final dayMatch = RegExp(r'^(\d+)\s+day[s]?\s+(.+)$').firstMatch(trimmed);

  int days = 0;
  String timePart = trimmed;
  if (dayMatch != null) {
    days = int.parse(dayMatch.group(1)!);
    timePart = dayMatch.group(2)!;
  }

  final timeMatch = RegExp(
    r'^(\d{1,2}):(\d{2}):(\d{2})(?:\.(\d{1,6}))?$',
  ).firstMatch(timePart);
  if (timeMatch == null) {
    throw FormatException('Invalid interval format: $value');
  }

  final hours = int.parse(timeMatch.group(1)!);
  final minutes = int.parse(timeMatch.group(2)!);
  final seconds = int.parse(timeMatch.group(3)!);
  final fraction = timeMatch.group(4);
  final micros = fraction == null ? 0 : int.parse(fraction.padRight(6, '0'));

  return Duration(
    hours: hours + (days * 24),
    minutes: minutes,
    seconds: seconds,
    microseconds: micros,
  );
}
