import 'package:flutter/material.dart';

/// Barberoo Farbsystem — 1:1 aus styles.css übernommen.
/// Wird als ThemeExtension bereitgestellt, damit Dark- und Hellmodus
/// dieselben Bezeichner nutzen. Zugriff über `context.c`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // Flächen
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color line;
  final Color line2;

  // Text
  final Color text;
  final Color text2;
  final Color text3;

  // Akzent — Terrakotta
  final Color accent;
  final Color accentBright;
  final Color accentSoft;
  final Color accentLine;

  // Status
  final Color ok;
  final Color okSoft;
  final Color warn;
  final Color warnSoft;
  final Color danger;
  final Color dangerSoft;

  // Akzent-Verlauf der Feature-Kachel
  final List<Color> featureGradient;

  // App-Außenraum (Body hinter dem zentrierten App-Rahmen)
  final Color shellBg;

  // Toast
  final Color toastBg;
  final Color toastText;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.line,
    required this.line2,
    required this.text,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.accentBright,
    required this.accentSoft,
    required this.accentLine,
    required this.ok,
    required this.okSoft,
    required this.warn,
    required this.warnSoft,
    required this.danger,
    required this.dangerSoft,
    required this.featureGradient,
    required this.shellBg,
    required this.toastBg,
    required this.toastText,
  });

  // ---------------- DUNKEL (Original) ----------------
  static const dark = AppColors(
    bg: Color(0xFF18181B),
    surface: Color(0xFF232327),
    surface2: Color(0xFF2C2C32),
    surface3: Color(0xFF36363D),
    line: Color(0x14FFFFFF), //  rgba(255,255,255,.08)
    line2: Color(0x24FFFFFF), // rgba(255,255,255,.14)
    text: Color(0xFFEDEDF0),
    text2: Color(0xFFA7A7B0),
    text3: Color(0xFF6F6F78),
    accent: Color(0xFFC06A4F),
    accentBright: Color(0xFFD07A5E),
    accentSoft: Color(0x29C06A4F), // rgba(192,106,79,.16)
    accentLine: Color(0x66C06A4F), // rgba(192,106,79,.40)
    ok: Color(0xFF6FAE8E),
    okSoft: Color(0x266FAE8E), //  rgba(111,174,142,.15)
    warn: Color(0xFFD6A44B),
    warnSoft: Color(0x26D6A44B), // rgba(214,164,75,.15)
    danger: Color(0xFFE08573),
    dangerSoft: Color(0x24E08573), // rgba(224,133,115,.14)
    featureGradient: [Color(0xFF6E3A2B), Color(0xFFC06A4F)],
    shellBg: Color(0xFF0E0E10),
    toastBg: Color(0xFFFFFFFF),
    toastText: Color(0xFF1A1A1A),
  );

  // ---------------- HELL (neu, gleiche Akzentwelt) ----------------
  static const light = AppColors(
    bg: Color(0xFFF5F3F0), //   warmes Off-White
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEFEDE9),
    surface3: Color(0xFFE5E2DC),
    line: Color(0x140F0F12), //  rgba(15,15,18,.08)
    line2: Color(0x240F0F12), // rgba(15,15,18,.14)
    text: Color(0xFF1F1F22),
    text2: Color(0xFF5C5C66),
    text3: Color(0xFF8E8E98),
    accent: Color(0xFFC06A4F),
    accentBright: Color(0xFFAE5A41), // dunkler für Kontrast auf Hell
    accentSoft: Color(0x1FC06A4F), //  rgba(192,106,79,.12)
    accentLine: Color(0x66C06A4F),
    ok: Color(0xFF3F9374),
    okSoft: Color(0x1F3F9374),
    warn: Color(0xFFB5852C),
    warnSoft: Color(0x1FB5852C),
    danger: Color(0xFFCB6450),
    dangerSoft: Color(0x1FCB6450),
    featureGradient: [Color(0xFF8A4634), Color(0xFFC06A4F)],
    shellBg: Color(0xFFE7E3DD),
    toastBg: Color(0xFF1F1F22),
    toastText: Color(0xFFF5F3F0),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      surface3: l(surface3, other.surface3),
      line: l(line, other.line),
      line2: l(line2, other.line2),
      text: l(text, other.text),
      text2: l(text2, other.text2),
      text3: l(text3, other.text3),
      accent: l(accent, other.accent),
      accentBright: l(accentBright, other.accentBright),
      accentSoft: l(accentSoft, other.accentSoft),
      accentLine: l(accentLine, other.accentLine),
      ok: l(ok, other.ok),
      okSoft: l(okSoft, other.okSoft),
      warn: l(warn, other.warn),
      warnSoft: l(warnSoft, other.warnSoft),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      featureGradient: [
        l(featureGradient.first, other.featureGradient.first),
        l(featureGradient.last, other.featureGradient.last),
      ],
      shellBg: l(shellBg, other.shellBg),
      toastBg: l(toastBg, other.toastBg),
      toastText: l(toastText, other.toastText),
    );
  }
}

/// Bequemer Zugriff: `context.c.accent`
extension AppColorsX on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
}
