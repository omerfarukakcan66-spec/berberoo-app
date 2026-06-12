import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../data/store.dart';
import '../data/models.dart';
import '../data/date_utils.dart';
import '../data/payment.dart';
import '../widgets/common.dart';
import '../widgets/rows.dart';
import '../widgets/inputs.dart';
import '../widgets/press_scale.dart';
import '../forms/open_forms.dart';

class CalendarScreen extends StatefulWidget {
  final AppStore store;
  const CalendarScreen({super.key, required this.store});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String mode = 'tag'; // tag | woche | monat
  String sel = D.todayISO();

  AppStore get store => widget.store;
  String get today => D.todayISO();

  void _open(Appointment a) => openAppointmentForm(context, store, initial: a);
  void _add(String date) =>
      openAppointmentForm(context, store, defaultDate: date, defaultTime: '10:00');

  void _step(int dir) {
    setState(() {
      if (mode == 'monat') {
        final d = D.parseISO(sel);
        sel = D.iso(DateTime(d.year, d.month + dir, d.day));
      } else if (mode == 'woche') {
        sel = D.addDays(sel, dir * 7);
      } else {
        sel = D.addDays(sel, dir);
      }
    });
  }

  String _headerTitle() {
    if (mode == 'monat') {
      final d = D.parseISO(sel);
      return '${D.mon[d.month - 1]} ${d.year}';
    } else if (mode == 'woche') {
      final ws = D.weekDays(sel);
      return '${D.fmtShort(ws[0])} – ${D.fmtShort(ws[6])}';
    }
    return D.fmtRel(sel);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Segmented(
          options: const [
            MapEntry('tag', 'Tag'),
            MapEntry('woche', 'Woche'),
            MapEntry('monat', 'Monat'),
          ],
          value: mode,
          onChanged: (v) => setState(() => mode = v),
        ),
        const SizedBox(height: 14),
        // Kopf mit Navigation
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              IconBtn('arrowL', iconSize: 20, onTap: () => _step(-1)),
              Expanded(
                child: PressScale(
                  onTap: () => setState(() => sel = today),
                  child: Text(
                    _headerTitle(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.01 * 16,
                        color: context.c.text),
                  ),
                ),
              ),
              IconBtn('arrowR', iconSize: 20, onTap: () => _step(1)),
            ],
          ),
        ),
        if (mode == 'tag')
          _DayTimeline(store: store, date: sel, onOpen: _open, onAdd: _add)
        else if (mode == 'woche')
          _weekView()
        else
          _monthView(),
      ],
    );
  }

  // ---------------- Woche ----------------
  Widget _weekView() {
    final c = context.c;
    final wd = D.weekDays(sel);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Row(
            children: [
              for (final d in wd)
                Expanded(
                  child: PressScale(
                    onTap: () => setState(() => sel = d),
                    child: _WeekCol(
                      weekday: D.wdShort[D.jsWeekday(D.parseISO(d))],
                      day: D.parseISO(d).day,
                      isToday: d == today,
                      isSel: d == sel && d != today,
                      dots: store.appts.where((a) => a.date == d).length.clamp(0, 3),
                    ),
                  ),
                ),
            ],
          ),
        ),
        _DayList(store: store, date: sel, onOpen: _open, onAdd: _add),
      ],
    );
  }

  // ---------------- Monat ----------------
  Widget _monthView() {
    final d = D.parseISO(sel);
    final y = d.year, m = d.month;
    final first = DateTime(y, m, 1);
    final startPad = (first.weekday % 7 + 6) % 7; // Mo=0
    final daysIn = DateTime(y, m + 1, 0).day;
    final cells = <String?>[];
    for (int i = 0; i < startPad; i++) {
      cells.add(null);
    }
    for (int day = 1; day <= daysIn; day++) {
      cells.add(D.iso(DateTime(y, m, day)));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final head = [...D.wdShort.sublist(1), D.wdShort[0]];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  for (final w in head)
                    Expanded(
                      child: Text(w,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: context.c.text3)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  for (final cell in cells) _monthCell(cell),
                ],
              ),
            ],
          ),
        ),
        _DayList(store: store, date: sel, onOpen: _open, onAdd: _add),
      ],
    );
  }

  Widget _monthCell(String? cell) {
    final c = context.c;
    if (cell == null) return const SizedBox.shrink();
    final n = store.appts.where((a) => a.date == cell).length;
    final dd = D.parseISO(cell).day;
    final isToday = cell == today;
    final isSel = cell == sel && cell != today;
    return PressScale(
      onTap: () => setState(() => sel = cell),
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? c.accent : c.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: isSel ? c.accentLine : Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$dd',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isToday ? Colors.white : c.text)),
            const SizedBox(height: 4),
            SizedBox(
              height: 5,
              child: n > 0
                  ? Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                          color: isToday ? Colors.white : c.accent, shape: BoxShape.circle),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Wochenspalte (.week-col)
class _WeekCol extends StatelessWidget {
  final String weekday;
  final int day;
  final bool isToday;
  final bool isSel;
  final int dots;
  const _WeekCol({
    required this.weekday,
    required this.day,
    required this.isToday,
    required this.isSel,
    required this.dots,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      children: [
        Text(weekday,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: c.text3)),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isToday ? c.accent : Colors.transparent,
            shape: BoxShape.circle,
            border: isSel ? Border.all(color: c.accentLine, width: 1.5) : null,
          ),
          child: Text('$day',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isToday ? Colors.white : c.text)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < dots; i++) ...[
                if (i > 0) const SizedBox(width: 3),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Tagesliste mit Karten (.DayList)
class _DayList extends StatelessWidget {
  final AppStore store;
  final String date;
  final void Function(Appointment) onOpen;
  final void Function(String) onAdd;
  const _DayList(
      {required this.store, required this.date, required this.onOpen, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final list = store.appts.where((a) => a.date == date).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final sum = list.fold<double>(0, (s, a) => s + a.price);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(D.fmtRel(date), trailing: Pill('${list.length} · ${D.euro(sum)} €')),
        if (list.isEmpty)
          const EmptyState(icon: 'calendar', text: 'Keine Termine an diesem Tag.')
        else
          Column(
            children: [
              for (final a in list) ...[
                _calendarApptTile(context, store, a, onOpen),
                if (a != list.last) const SizedBox(height: 10),
              ],
            ],
          ),
        const SizedBox(height: 12),
        AppButton('Termin am ${D.fmtShort(date)}', icon: 'plus', onTap: () => onAdd(date)),
      ],
    );
  }
}

ApptTile _calendarApptTile(
    BuildContext context, AppStore store, Appointment a, void Function(Appointment) onOpen) {
  return ApptTile(
    timeTop: a.time,
    timeBottom: D.addMinutes(a.time, a.duration),
    who: store.custName(a.customerId),
    what: '${a.serviceName} · ${a.duration} min',
    note: a.notiz.isNotEmpty ? a.notiz : null,
    pay: a.pay,
    priceLabel: '${D.euro(a.price)} €',
    onTap: () => onOpen(a),
  );
}

/// Tagesansicht mit 30-Min-Timeline (.DayTimeline)
class _DayTimeline extends StatelessWidget {
  final AppStore store;
  final String date;
  final void Function(Appointment) onOpen;
  final void Function(String) onAdd;
  const _DayTimeline(
      {required this.store, required this.date, required this.onOpen, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final list = store.appts.where((a) => a.date == date).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final sum = list.fold<double>(0, (s, a) => s + a.price);

    // 30-Min-Slots innerhalb Arbeitszeiten
    final startMin = store.workStart * 60;
    final endMin = store.workEnd * 60;
    final slots = <int>[];
    for (int m = startMin; m < endMin; m += 30) {
      slots.add(m);
    }

    // Slots rendern — Termine überspannen, freie Lücken sichtbar machen
    final rows = <Widget>[];
    int skipUntil = -1;
    int? freeFrom;

    void flushFree(int until) {
      if (freeFrom != null) {
        rows.add(_FreeSlot(fromMin: freeFrom!, toMin: until));
        freeFrom = null;
      }
    }

    for (final slotMin in slots) {
      // Termin der in diesem Slot beginnt?
      final appt = list.cast<Appointment?>().firstWhere(
        (a) => D.minutesOf(a!.time) >= slotMin && D.minutesOf(a.time) < slotMin + 30,
        orElse: () => null,
      );

      if (appt != null) {
        flushFree(slotMin);
        skipUntil = D.minutesOf(appt.time) + appt.duration;
        rows.add(_SlotRow(
          slotMin: slotMin,
          c: c,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TimelineAppt(store: store, a: appt, onTap: () => onOpen(appt)),
            ],
          ),
        ));
      } else if (slotMin < skipUntil) {
        // von laufendem Termin überdeckt — überspringen
        continue;
      } else {
        // freier Slot
        freeFrom ??= slotMin;
      }
    }
    flushFree(endMin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(D.fmtRel(date), trailing: Pill('${list.length} · ${D.euro(sum)} €')),
        ...rows,
        const SizedBox(height: 14),
        AppButton('Termin hinzufügen', icon: 'plus', onTap: () => onAdd(date)),
      ],
    );
  }
}

class _SlotRow extends StatelessWidget {
  final int slotMin;
  final AppColors c;
  final Widget child;
  const _SlotRow({required this.slotMin, required this.c, required this.child});

  @override
  Widget build(BuildContext context) {
    final h = slotMin ~/ 60;
    final m = slotMin % 60;
    final label = '${D.pad(h)}:${D.pad(m)}';
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 12),
              child: Text(label,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.text3)),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeSlot extends StatelessWidget {
  final int fromMin;
  final int toMin;
  const _FreeSlot({required this.fromMin, required this.toMin});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fh = fromMin ~/ 60, fm = fromMin % 60;
    final th = toMin ~/ 60, tm = toMin % 60;
    final label = '${D.pad(fh)}:${D.pad(fm)}';
    final dauer = toMin - fromMin;
    final durLabel = dauer >= 60
        ? '${dauer ~/ 60} Std${dauer % 60 > 0 ? ' ${dauer % 60} Min' : ''} frei'
        : '$dauer Min frei';
    final endLabel = '${D.pad(th)}:${D.pad(tm)}';
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 12),
              child: Text(label,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.text3)),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.line)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 32,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: c.ok.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(durLabel,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: c.ok)),
                        Text('bis $endLabel Uhr',
                            style: TextStyle(fontSize: 12, color: c.text3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// .tl-appt
class _TimelineAppt extends StatelessWidget {
  final AppStore store;
  final Appointment a;
  final VoidCallback onTap;
  const _TimelineAppt({required this.store, required this.a, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = payMeta(a.pay, c);
    return PressScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.accentSoft,
          borderRadius: BorderRadius.circular(11),
          border: Border(
            top: BorderSide(color: c.accentLine),
            right: BorderSide(color: c.accentLine),
            bottom: BorderSide(color: c.accentLine),
            left: BorderSide(color: m.dot, width: 3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.custName(a.customerId),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14.5, color: c.text)),
                  const SizedBox(height: 1),
                  Text('${a.serviceName} · ${a.duration} min',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: c.text2)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${a.time} – ${D.addMinutes(a.time, a.duration)} Uhr',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: c.accentBright)),
                      if (a.pay != 'offen') ...[
                        const SizedBox(width: 8),
                        PayBadge(pay: a.pay),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Text('${D.euro(a.price)} €',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: c.text)),
          ],
        ),
      ),
    );
  }
}
