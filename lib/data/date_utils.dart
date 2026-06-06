import 'dart:math';

/// Barberoo — Datums- & Formatierungs-Helfer.
/// Portierung von store.js (deutsche Wochentage/Monate, Montag als Wochenstart).
class D {
  static const wd = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'];
  static const wdShort = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
  static const mon = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];
  static const monShort = [
    'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'
  ];

  static String pad(int n) => n.toString().padLeft(2, '0');

  static String iso(DateTime d) => '${d.year}-${pad(d.month)}-${pad(d.day)}';

  static DateTime parseISO(String s) {
    final p = s.split('-').map(int.parse).toList();
    return DateTime(p[0], p[1], p[2]);
  }

  static String todayISO() => iso(DateTime.now());

  static String addDays(String s, int n) {
    final d = parseISO(s);
    return iso(DateTime(d.year, d.month, d.day + n));
  }

  /// JS getDay(): So=0 … Sa=6
  static int jsWeekday(DateTime d) => d.weekday % 7;

  /// Montag als Wochenstart.
  static String weekStart(String s) {
    final d = parseISO(s);
    final day = (jsWeekday(d) + 6) % 7; // Mo = 0
    return iso(DateTime(d.year, d.month, d.day - day));
  }

  static List<String> weekDays(String s) {
    final ws = weekStart(s);
    return List.generate(7, (i) => addDays(ws, i));
  }

  static bool sameWeek(String a, String b) => weekStart(a) == weekStart(b);

  static String fmtLong(String s) {
    final d = parseISO(s);
    return '${wd[jsWeekday(d)]}, ${d.day}. ${mon[d.month - 1]}';
  }

  static String fmtShort(String s) {
    final d = parseISO(s);
    return '${d.day}. ${monShort[d.month - 1]}';
  }

  static String fmtRel(String s) {
    final t = todayISO();
    if (s == t) return 'Heute';
    if (s == addDays(t, 1)) return 'Morgen';
    if (s == addDays(t, -1)) return 'Gestern';
    return fmtLong(s);
  }

  /// Deutsche Euro-Zahl: ganze Zahl ohne Nachkomma, sonst 2 Stellen.
  /// 28 -> "28", 28.5 -> "28,50", 1234.5 -> "1.234,50"
  static String euro(num n) {
    final rounded = (n * 100).round() / 100;
    final hasFraction = rounded % 1 != 0;
    final neg = rounded < 0;
    final abs = rounded.abs();

    final intPart = abs.truncate();
    final intStr = _thousands(intPart);

    String out;
    if (hasFraction) {
      final cents = ((abs - intPart) * 100).round().toString().padLeft(2, '0');
      out = '$intStr,$cents';
    } else {
      out = intStr;
    }
    return neg ? '-$out' : out;
  }

  static String _thousands(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String addMinutes(String time, int mins) {
    final parts = time.split(':').map(int.parse).toList();
    final total = parts[0] * 60 + parts[1] + mins;
    return '${pad((total ~/ 60) % 24)}:${pad(total % 60)}';
  }

  static int minutesOf(String time) {
    final parts = time.split(':').map(int.parse).toList();
    return parts[0] * 60 + parts[1];
  }

  static final _rand = Random();
  static String uid() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
      _rand.nextInt(1 << 30).toRadixString(36).padLeft(5, '0').substring(0, 5);
}
