import '../models/campus_event.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String two(int n) => n.toString().padLeft(2, '0');

/// 18 Oct
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// 18 Oct 2026
String formatDay(DateTime d) => '${formatDate(d)} ${d.year}';

/// 10:00
String formatTime(DateTime d) => '${two(d.hour)}:${two(d.minute)}';

/// 18 Oct, 10:00
String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

String formatDuration(Duration d) {
  if (d.inDays >= 1) return '${d.inDays} d ${d.inHours % 24} h';
  if (d.inHours >= 1) return '${d.inHours} h ${d.inMinutes % 60} min';
  return '${d.inMinutes} min';
}

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// R9: exhaustive switch expression over the sealed class.
String countdownText(Countdown c) => switch (c) {
      Upcoming(left: var left) => 'Starts in ${formatDuration(left)}',
      Started(ago: var ago) => 'Started ${formatDuration(ago)} ago',
      Ended() => 'Ended',
    };
