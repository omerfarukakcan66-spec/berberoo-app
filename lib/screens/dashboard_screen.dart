import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../data/store.dart';
import '../data/models.dart';
import '../data/date_utils.dart';
import '../data/payment.dart';
import '../widgets/common.dart';
import '../widgets/rows.dart';
import '../forms/open_forms.dart';

class DashboardScreen extends StatelessWidget {
  final AppStore store;
  const DashboardScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final today = D.todayISO();
    final now = DateTime.now();
    final nowStr = '${D.pad(now.hour)}:${D.pad(now.minute)}';
    final todayAppts = store.appts.where((a) => a.date == today && !a.done).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final nextAppt = todayAppts.where((a) => a.time.compareTo(nowStr) >= 0).cast<Appointment?>().firstWhere((_) => true, orElse: () => null);
    final weekAppts = store.appts.where((a) => D.sameWeek(a.date, today)).toList();

    final revToday = todayAppts.fold<double>(0, (s, a) => s + a.price);
    final revWeek = weekAppts.fold<double>(0, (s, a) => s + a.price);
    final openToday =
        todayAppts.where((a) => isOutstanding(a.pay)).fold<double>(0, (s, a) => s + a.price);
    final openWeek =
        weekAppts.where((a) => isOutstanding(a.pay)).fold<double>(0, (s, a) => s + a.price);

    final days = D.weekDays(today);
    final perDay = days.map((d) {
      final sum = store.appts.where((a) => a.date == d).fold<double>(0, (s, a) => s + a.price);
      return _DayBar(D.wdShort[D.jsWeekday(D.parseISO(d))], sum, d == today);
    }).toList();
    final maxDay = [1.0, ...perDay.map((x) => x.sum)].reduce((a, b) => a > b ? a : b);

    final h = DateTime.now().hour;
    final greeting = h < 11 ? 'Guten Morgen' : (h < 18 ? 'Hallo' : 'Guten Abend');

    void openAppt(Appointment a) => openAppointmentForm(context, store, initial: a);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 2),
        if (nextAppt != null) ...[
          _NextCustomerCard(appt: nextAppt, customerName: store.custName(nextAppt.customerId)),
          const SizedBox(height: 16),
        ],
        LabelText('$greeting 👋', margin: const EdgeInsets.fromLTRB(2, 0, 2, 12)),
        // Stat-Grid 1
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: 'Umsatz heute',
                value: '€ ${D.euro(revToday)}',
                meta: openToday > 0
                    ? 'davon ${D.euro(openToday)} € offen'
                    : '${todayAppts.length} ${todayAppts.length == 1 ? 'Termin' : 'Termine'}',
                feature: true,
                curency: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stat(
                label: 'Umsatz Woche',
                value: '€ ${D.euro(revWeek)}',
                meta: openWeek > 0
                    ? 'davon ${D.euro(openWeek)} € offen'
                    : '${weekAppts.length} Termine gesamt',
                curency: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Stat-Grid 2
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: 'Termine heute',
                value: '${todayAppts.length}',
                meta: todayAppts.isNotEmpty ? 'ab ${todayAppts.first.time} Uhr' : 'frei',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stat(label: 'Termine Woche', value: '${weekAppts.length}', meta: 'Mo – So'),
            ),
          ],
        ),
        // Wochengrafik
        const SectionTitle('Umsatz diese Woche'),
        AppCard(
          child: SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < perDay.length; i++) ...[
                  if (i > 0) const SizedBox(width: 9),
                  Expanded(child: _ChartBar(bar: perDay[i], maxDay: maxDay)),
                ],
              ],
            ),
          ),
        ),
        // Heutige Termine
        SectionTitle('Heutige Termine', trailing: Pill('${todayAppts.length}')),
        if (todayAppts.isEmpty)
          const EmptyState(icon: 'calendar', text: 'Heute keine Termine. Genieß den ruhigen Tag.')
        else
          Column(
            children: [
              for (final a in todayAppts) ...[
                ApptTile(
                  timeTop: a.time,
                  timeBottom: '${a.duration} min',
                  who: store.custName(a.customerId),
                  what: a.serviceName,
                  pay: a.pay,
                  priceLabel: '${D.euro(a.price)} €',
                  onTap: () => openAppt(a),
                ),
                if (a != todayAppts.last) const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }
}

class _NextCustomerCard extends StatelessWidget {
  final Appointment appt;
  final String customerName;
  const _NextCustomerCard({required this.appt, required this.customerName});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFAD5840); // mattes Orange
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NÄCHSTER KUNDE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.14 * 11,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            customerName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                appt.time,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${appt.serviceName} · ${appt.duration} min',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayBar {
  final String label;
  final double sum;
  final bool isToday;
  _DayBar(this.label, this.sum, this.isToday);
}

class _ChartBar extends StatelessWidget {
  final _DayBar bar;
  final double maxDay;
  const _ChartBar({required this.bar, required this.maxDay});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    const barMax = 82.0; // verbleibende Höhe für den Balken (Rest = Label + Lücke)
    final hpx = bar.sum > 0 ? (bar.sum / maxDay * barMax).clamp(6.0, barMax) : 2.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: hpx),
          duration: const Duration(milliseconds: 400),
          curve: const Cubic(.2, .7, .2, 1),
          builder: (_, v, __) => Container(
            width: double.infinity,
            height: v,
            decoration: BoxDecoration(
              color: bar.isToday ? c.accent : c.surface3,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(7), bottom: Radius.circular(4)),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(bar.label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: bar.isToday ? c.accentBright : c.text3)),
      ],
    );
  }
}

/// .stat / .stat.feature
class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String? meta;
  final bool feature;
  final bool curency;
  const _Stat({
    required this.label,
    required this.value,
    this.meta,
    this.feature = false,
    this.curency = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final onFeature = feature;
    final labelColor = onFeature ? Colors.white.withOpacity(0.75) : c.text3;
    final valColor = onFeature ? Colors.white : c.text;
    final metaColor = onFeature ? Colors.white : c.text2;

    // Währungszeichen kleiner & gedämpft
    Widget valueWidget;
    if (curency && value.startsWith('€ ')) {
      valueWidget = RichText(
        text: TextSpan(
          style: AppFonts.serif(TextStyle(fontSize: 34, height: 1, color: valColor)),
          children: [
            TextSpan(
                text: '€ ',
                style: TextStyle(
                    fontSize: 19,
                    color: onFeature ? Colors.white.withOpacity(0.8) : c.text2)),
            TextSpan(text: value.substring(2)),
          ],
        ),
      );
    } else {
      valueWidget = Text(value,
          style: AppFonts.serif(TextStyle(fontSize: 34, height: 1, color: valColor)));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: onFeature ? null : c.surface,
        gradient: onFeature
            ? LinearGradient(
                colors: c.featureGradient,
                begin: const Alignment(-0.7, -1),
                end: const Alignment(0.7, 1),
              )
            : null,
        borderRadius: BorderRadius.circular(R.md),
        border: Border.all(color: onFeature ? Colors.transparent : c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.14 * 11,
                  fontWeight: FontWeight.w700,
                  color: labelColor)),
          const SizedBox(height: 8),
          valueWidget,
          if (meta != null) ...[
            const SizedBox(height: 7),
            Text(meta!, style: TextStyle(fontSize: 12.5, color: metaColor)),
          ],
        ],
      ),
    );
  }
}
