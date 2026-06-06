import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Steuert den Erscheinungsmodus (System / Hell / Dunkel) und merkt ihn sich.
class ThemeController extends ChangeNotifier {
  static const _key = 'barberoo_thememode';
  ThemeMode _mode = ThemeMode.dark; // Standard wie das Original: dunkel
  ThemeMode get mode => _mode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    _mode = switch (v) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode m) async {
    _mode = m;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, m.name);
  }
}
