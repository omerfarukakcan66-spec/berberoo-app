import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'press_scale.dart';

String initialsOf(String name) {
  if (name.trim().isEmpty) return '?';
  final p = name.trim().split(RegExp(r'\s+'));
  final s = ((p.isNotEmpty ? p[0][0] : '') + (p.length > 1 ? p[1][0] : '')).toUpperCase();
  return s.isEmpty ? '?' : s;
}

/// .card
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.radius = R.md,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: c.line),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return PressScale(onTap: onTap, scale: 0.985, child: box);
  }
}

/// .label — Versalien, weite Laufweite
class LabelText extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  const LabelText(this.text, {super.key, this.margin, this.color});

  @override
  Widget build(BuildContext context) {
    final w = Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 0.14 * 11,
        fontWeight: FontWeight.w700,
        color: color ?? context.c.text3,
        height: 1.3,
      ),
    );
    return margin == null ? w : Padding(padding: margin!, child: w);
  }
}

/// .section-title (Titel links, optional rechts ein Link/Element)
class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionTitle(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 26, 2, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.01 * 16,
                color: context.c.text,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// .section-title .link
class LinkButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const LinkButton(this.text, {super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Text(text,
          style: TextStyle(
              color: context.c.accentBright, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

/// .pill
class Pill extends StatelessWidget {
  final String text;
  final Color? bg;
  final Color? fg;
  final Color? border;
  const Pill(this.text, {super.key, this.bg, this.fg, this.border});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? c.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border ?? c.line),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg ?? c.text2)),
    );
  }
}

/// .avatar (Kreis mit Initialen) — größenvariabel
class Avatar extends StatelessWidget {
  final String name;
  final double size;
  const Avatar({super.key, required this.name, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          color: c.accentBright,
          fontWeight: FontWeight.w700,
          fontSize: size * (16 / 44),
        ),
      ),
    );
  }
}

/// .stbadge — Zahlungsstatus
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final Color dot;
  const StatusBadge(
      {super.key, required this.label, required this.color, required this.bg, required this.dot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 3, 9, 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          Text(label,
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: color, height: 1.4)),
        ],
      ),
    );
  }
}

/// .empty — Leerzustand
class EmptyState extends StatelessWidget {
  final String icon;
  final String text;
  const EmptyState({super.key, this.icon = 'note', required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(bottom: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: c.surface2, borderRadius: BorderRadius.circular(18)),
            child: AppIcon(icon, size: 26, color: c.text3),
          ),
          Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.5, color: c.text3)),
        ],
      ),
    );
  }
}

enum BtnVariant { neutral, primary, ghost, danger }

/// .btn — Vollbreiten-Button mit Varianten
class AppButton extends StatelessWidget {
  final String label;
  final String? icon;
  final VoidCallback? onTap;
  final BtnVariant variant;
  final EdgeInsetsGeometry? margin;
  const AppButton(
    this.label, {
    super.key,
    this.icon,
    this.onTap,
    this.variant = BtnVariant.neutral,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    late Color bg, fg, border;
    switch (variant) {
      case BtnVariant.primary:
        bg = c.accent;
        fg = Colors.white;
        border = Colors.transparent;
        break;
      case BtnVariant.ghost:
        bg = Colors.transparent;
        fg = c.text;
        border = Colors.transparent;
        break;
      case BtnVariant.danger:
        bg = Colors.transparent;
        fg = c.danger;
        border = c.danger.withOpacity(0.35);
        break;
      case BtnVariant.neutral:
        bg = c.surface2;
        fg = c.text;
        border = c.line;
        break;
    }
    final btn = PressScale(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              AppIcon(icon!, size: 19, color: fg),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: fg)),
            ),
          ],
        ),
      ),
    );
    return margin == null ? btn : Padding(padding: margin!, child: btn);
  }
}

/// .icon-btn — runder Icon-Knopf (44px)
class IconBtn extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;
  final bool accent;
  final double size;
  final double iconSize;
  const IconBtn(
    this.icon, {
    super.key,
    this.onTap,
    this.accent = false,
    this.size = 44,
    this.iconSize = 21,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PressScale(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent ? c.accent : c.surface2,
          shape: BoxShape.circle,
          border: Border.all(color: accent ? Colors.transparent : c.line),
        ),
        child: AppIcon(icon, size: iconSize, color: accent ? Colors.white : c.text2),
      ),
    );
  }
}

/// Chevron am Zeilenende (.chev)
class Chevron extends StatelessWidget {
  const Chevron({super.key});
  @override
  Widget build(BuildContext context) =>
      AppIcon('chevron', size: 20, color: context.c.text3);
}
