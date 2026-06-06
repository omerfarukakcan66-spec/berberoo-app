import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../data/store.dart';
import '../data/theme_controller.dart';
import '../widgets/common.dart';
import '../widgets/app_icon.dart';
import '../widgets/inputs.dart';
import '../widgets/press_scale.dart';
import '../widgets/sheet.dart';
import '../widgets/toast.dart';

/// Einstellbereich — Erscheinungsbild (Dark/Hell), Salon, Daten.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final store = context.watch<AppStore>();
    final theme = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Dim.appMax),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kopf
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
                  child: Row(
                    children: [
                      IconBtn('arrowL', iconSize: 20, onTap: () => Navigator.of(context).pop()),
                      const SizedBox(width: 12),
                      Text('Einstellungen',
                          style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.02 * 27,
                              color: c.text)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                    children: [
                      // ---------- Erscheinungsbild ----------
                      const LabelText('Erscheinungsbild',
                          margin: EdgeInsets.fromLTRB(2, 14, 2, 12)),
                      Row(
                        children: [
                          Expanded(
                            child: _ThemeOption(
                              icon: 'sun',
                              label: 'Hell',
                              active: theme.mode == ThemeMode.light,
                              onTap: () => theme.setMode(ThemeMode.light),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ThemeOption(
                              icon: 'moon',
                              label: 'Dunkel',
                              active: theme.mode == ThemeMode.dark,
                              onTap: () => theme.setMode(ThemeMode.dark),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ThemeOption(
                              icon: 'phone_device',
                              label: 'System',
                              active: theme.mode == ThemeMode.system,
                              onTap: () => theme.setMode(ThemeMode.system),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 12, 2, 0),
                        child: Text(
                          'Bei „System“ folgt die App automatisch dem Erscheinungsbild deines Geräts.',
                          style: TextStyle(fontSize: 13, color: c.text2, height: 1.45),
                        ),
                      ),

                      // ---------- Salon ----------
                      const SectionTitle('Salon'),
                      AppCard(
                        onTap: () => _editSalon(context, store),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: c.accentSoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AppIcon('scissors', size: 20, color: c.accentBright),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const LabelText('Name'),
                                  const SizedBox(height: 3),
                                  Text(store.salon,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: c.text)),
                                ],
                              ),
                            ),
                            AppIcon('edit', size: 19, color: c.text3),
                          ],
                        ),
                      ),

                      // ---------- Daten ----------
                      const SectionTitle('Daten'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
                        child: Text(
                          store.seeded
                              ? 'Aktuell sind Beispieldaten geladen. Du kannst alles löschen und leer starten.'
                              : 'Du arbeitest mit deinen eigenen Daten.',
                          style: TextStyle(fontSize: 14, color: c.text2, height: 1.45),
                        ),
                      ),
                      AppButton('Beispieldaten laden', icon: 'sparkle', onTap: () {
                        showConfirm(
                          context,
                          title: 'Beispieldaten laden?',
                          message:
                              'Alle aktuellen Termine, Kunden und Leistungen werden durch Beispieldaten ersetzt.',
                          confirmLabel: 'Beispieldaten laden',
                          danger: false,
                          onConfirm: () {
                            store.loadDemo();
                            Toast.show(context, 'Beispieldaten geladen');
                          },
                        );
                      }),
                      const SizedBox(height: 10),
                      AppButton('Alle Daten löschen',
                          icon: 'trash', variant: BtnVariant.danger, onTap: () {
                        showConfirm(
                          context,
                          title: 'Alle Daten löschen?',
                          message:
                              'Sämtliche Termine, Kunden, Leistungen und Aufgaben werden unwiderruflich entfernt.',
                          confirmLabel: 'Alles löschen',
                          onConfirm: () {
                            store.clearAll();
                            Toast.show(context, 'Alle Daten gelöscht');
                          },
                        );
                      }),

                      // ---------- Info ----------
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Divider(height: 1, color: c.line),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 18, 8, 0),
                        child: Text(
                          'Alle Daten werden lokal auf diesem Gerät gespeichert und bleiben nach dem Neustart erhalten.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: c.text2, height: 1.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('Barberoo · Version 1.0',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: c.text3)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editSalon(BuildContext context, AppStore store) {
    final ctrl = TextEditingController(text: store.salon);
    showAppSheet(
      context: context,
      title: 'Salon-Name',
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppField(
            label: 'Wie heißt dein Salon?',
            child: AppTextField(controller: ctrl, hint: 'Barberoo', autofocus: true),
          ),
          const SizedBox(height: 4),
          AppButton('Speichern', variant: BtnVariant.primary, onTap: () {
            store.setSalon(ctrl.text);
            Toast.show(ctx, 'Gespeichert');
            Navigator.of(ctx).pop();
          }),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: active ? c.accentSoft : c.surface,
          borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: active ? c.accentLine : c.line, width: active ? 1.5 : 1),
        ),
        child: Column(
          children: [
            AppIcon(icon, size: 26, color: active ? c.accentBright : c.text2),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: active ? c.accentBright : c.text2)),
          ],
        ),
      ),
    );
  }
}
