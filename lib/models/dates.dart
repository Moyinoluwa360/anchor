/// Date helpers. A "day" is local midnight; a week starts on Monday so the
/// Sunday review closes it.
DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

DateTime today([DateTime? now]) => dayOf(now ?? DateTime.now());

DateTime weekStartOf(DateTime t) {
  final d = dayOf(t);
  return d.subtract(Duration(days: d.weekday - DateTime.monday));
}

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Adds whole calendar days without DST drift.
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

/// "09:30"
String hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "24:59" style countdown; hours shown only when needed.
String clock(Duration d) {
  final neg = d.isNegative;
  final s = d.inSeconds.abs();
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  final body = h > 0
      ? '$h:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}'
      : '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  return neg ? '-$body' : body;
}

/// "1h 30m", "45m"
String minutesLabel(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final h = minutes ~/ 60, m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const monthShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String dayLabel(DateTime d) => '${weekdayShort[d.weekday - 1]} ${d.day} ${monthShort[d.month - 1]}';
