import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../data/payment.dart';
import 'press_scale.dart';
import 'common.dart';

/// .stbadge über payMeta aufgelöst
class PayBadge extends StatelessWidget {
  final String pay;
  const PayBadge({super.key, required this.pay});
  @override
  Widget build(BuildContext context) {
    final m = payMeta(pay, context.c);
    return StatusBadge(label: m.label, color: m.color, bg: m.bg, dot: m.dot);
  }
}

/// .appt — Terminkachel (flexibel für Dashboard, Kalender, Kundendetail)
class ApptTile extends StatelessWidget {
  final String timeTop;
  final String timeBottom;
  final double timeTopSize;
  final String who;
  final String what;
  final String? note; // ✦ Notiz-Zeile (Akzentfarbe)
  final String pay;
  final String priceLabel;
  final VoidCallback? onTap;

  const ApptTile({
    super.key,
    required this.timeTop,
    required this.timeBottom,
    this.timeTopSize = 16,
    required this.who,
    required this.what,
    this.note,
    required this.pay,
    required this.priceLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final bar = payMeta(pay, c).bar;
    final content = Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(R.md),
        border: Border.all(color: c.line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Zeit-Spalte
            SizedBox(
              width: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(timeTop,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: timeTopSize, color: c.text)),
                  const SizedBox(height: 2),
                  Text(timeBottom,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: c.text3)),
                ],
              ),
            ),
            const SizedBox(width: 13),
            // Statusbalken
            Container(
              width: 3,
              decoration:
                  BoxDecoration(color: bar, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: 13),
            // Körper
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(who,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15.5, color: c.text)),
                  const SizedBox(height: 1),
                  Text(what,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, color: c.text2)),
                  if (note != null && note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('✦ ${note!}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13.5, color: c.accentBright)),
                  ],
                  if (pay != 'offen') ...[
                    const SizedBox(height: 4),
                    PayBadge(pay: pay),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Preis
            Text(priceLabel,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: c.text)),
          ],
        ),
      ),
    );
    if (onTap == null) return content;
    return PressScale(onTap: onTap, scale: 0.99, child: content);
  }
}

/// .row — generische Listenzeile mit Avatar/Icon links, Titel/Untertitel, Ende-Slot
class ListRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool chevron;
  final VoidCallback? onTap;

  const ListRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.chevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final content = Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(R.md),
        border: Border.all(color: c.line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15.5, color: c.text)),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: c.text2)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          if (chevron) ...[const SizedBox(width: 8), const Chevron()],
        ],
      ),
    );
    if (onTap == null) return content;
    return PressScale(onTap: onTap, scale: 0.99, child: content);
  }
}
