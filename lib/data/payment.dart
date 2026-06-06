import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Barberoo — Zahlungsstatus. Reihenfolge & Bedeutung wie im JS-Store.
class PayMeta {
  final String label;
  final Color color; // Textfarbe im Badge
  final Color bg; //    Badge-Hintergrund
  final Color dot; //   Punktfarbe
  final Color bar; //   Markierung links an der Terminkarte
  const PayMeta(this.label, this.color, this.bg, this.dot, this.bar);
}

const List<String> kPayOrder = ['offen', 'bezahlt', 'spaeter', 'nicht'];

PayMeta payMeta(String? pay, AppColors c) {
  switch (pay) {
    case 'bezahlt':
      return PayMeta('Bezahlt', c.ok, c.okSoft, c.ok, c.ok);
    case 'spaeter':
      return PayMeta('Zahlt später', c.warn, c.warnSoft, c.warn, c.warn);
    case 'nicht':
      return PayMeta('Nicht bezahlt', c.danger, c.dangerSoft, c.danger, c.danger);
    case 'offen':
    default:
      return PayMeta('Offen', c.text2, c.surface2, c.text3, c.accent);
  }
}

bool isCollected(String pay) => pay == 'bezahlt';
bool isOutstanding(String pay) => pay == 'spaeter' || pay == 'nicht';
