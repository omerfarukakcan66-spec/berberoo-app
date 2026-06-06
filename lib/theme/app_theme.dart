import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Radien & Maße — 1:1 aus styles.css (:root).
class R {
  static const double sm = 10;
  static const double md = 16; //  --r
  static const double lg = 22;
  static const double xl = 28;
}

/// Breite des zentrierten App-Rahmens (--app-max) und Navhöhe (--nav-h).
class Dim {
  static const double appMax = 480;
  static const double navH = 76;
}

/// Schatten aus dem Original.
class Shadows {
  static List<BoxShadow> card(BuildContext _) => const [
        BoxShadow(color: Color(0x59000000), blurRadius: 30, offset: Offset(0, 8)),
      ];
  static List<BoxShadow> lg() => const [
        BoxShadow(color: Color(0x80000000), blurRadius: 50, offset: Offset(0, 18)),
      ];
}

/// Schrift: Hanken Grotesk (Sans) + Instrument Serif (Zahlen/Logo).
class AppFonts {
  static TextStyle sans([TextStyle? base]) => GoogleFonts.hankenGrotesk(textStyle: base);
  static TextStyle serif([TextStyle? base]) => GoogleFonts.instrumentSerif(textStyle: base);
}

ThemeData buildTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final base = ThemeData(brightness: brightness, useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: colors.bg,
    extensions: [colors],
    colorScheme: base.colorScheme.copyWith(
      brightness: brightness,
      primary: colors.accent,
      surface: colors.surface,
      onSurface: colors.text,
    ),
    textTheme: GoogleFonts.hankenGroteskTextTheme(base.textTheme).apply(
      bodyColor: colors.text,
      displayColor: colors.text,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
  );
}
