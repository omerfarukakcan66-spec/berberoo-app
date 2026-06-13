import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

                      // ---------- Arbeitszeiten ----------
                      const SectionTitle('Arbeitszeiten'),
                      AppCard(
                        onTap: () => _editWorkHours(context, store),
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
                              child: AppIcon('clock', size: 20, color: c.accentBright),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const LabelText('Arbeitszeiten'),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${_fmtH(store.workStart)} – ${_fmtH(store.workEnd)} Uhr',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: c.text),
                                  ),
                                ],
                              ),
                            ),
                            AppIcon('edit', size: 19, color: c.text3),
                          ],
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

                      // ---------- Sicherung ----------
                      const SectionTitle('Sicherung'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
                        child: Text(
                          'Exportiere deine Daten vor einem Update. Importiere sie danach wieder.',
                          style: TextStyle(fontSize: 13.5, color: c.text2, height: 1.45),
                        ),
                      ),
                      AppButton('Daten exportieren', icon: 'share',
                          onTap: () => _export(context, store)),
                      const SizedBox(height: 10),
                      AppButton('Daten importieren', icon: 'download',
                          onTap: () => _import(context, store)),

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

  Future<void> _export(BuildContext context, AppStore store) async {
    try {
      final json = store.exportJson();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/barberoo_sicherung.json');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Barberoo Sicherung',
      );
    } catch (e) {
      if (context.mounted) Toast.show(context, 'Export fehlgeschlagen');
    }
  }

  void _import(BuildContext context, AppStore store) {
    final ctrl = TextEditingController();
    showAppSheet(
      context: context,
      title: 'Daten importieren',
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
            child: Text(
              'Füge den Inhalt deiner Sicherungsdatei hier ein.',
              style: TextStyle(fontSize: 13.5, color: ctx.c.text2),
            ),
          ),
          AppField(
            label: 'JSON einfügen',
            child: AppTextField(
              controller: ctrl,
              hint: '{"services": [...], "customers": [...], ...}',
              minLines: 4,
              maxLines: 8,
            ),
          ),
          const SizedBox(height: 4),
          AppButton('Aus Zwischenablage', onTap: () async {
            final data = await Clipboard.getData('text/plain');
            if (data?.text != null) ctrl.text = data!.text!;
          }),
          const SizedBox(height: 10),
          AppButton('Importieren & Wiederherstellen',
              variant: BtnVariant.primary,
              onTap: () {
                if (ctrl.text.trim().isEmpty) return;
                showConfirm(
                  ctx,
                  title: 'Daten überschreiben?',
                  message: 'Aktuelle Daten werden durch die Sicherung ersetzt.',
                  confirmLabel: 'Importieren',
                  danger: true,
                  onConfirm: () {
                    final err = store.importJson(ctrl.text.trim());
                    if (err != null) {
                      Toast.show(ctx, err);
                    } else {
                      Toast.show(ctx, 'Daten wiederhergestellt ✓');
                      Navigator.of(ctx).pop();
                    }
                  },
                );
              }),
        ],
      ),
    );
  }

  static String _fmtH(int h) => '${h.toString().padLeft(2, '0')}:00';

  void _editWorkHours(BuildContext context, AppStore store) {
    int start = store.workStart;
    int end = store.workEnd;
    showAppSheet(
      context: context,
      title: 'Arbeitszeiten',
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppField(
                    label: 'Beginn',
                    child: _HourPicker(
                      value: start,
                      min: 0,
                      max: end - 1,
                      onChange: (v) => setSt(() => start = v),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppField(
                    label: 'Ende',
                    child: _HourPicker(
                      value: end,
                      min: start + 1,
                      max: 24,
                      onChange: (v) => setSt(() => end = v),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppButton('Speichern', variant: BtnVariant.primary, onTap: () {
              store.setWorkHours(start, end);
              Toast.show(ctx, 'Gespeichert');
              Navigator.of(ctx).pop();
            }),
          ],
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

class _HourPicker extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChange;
  const _HourPicker({required this.value, required this.min, required this.max, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          _btn(c, '−', value > min ? () => onChange(value - 1) : null),
          Expanded(
            child: Text(
              '${value.toString().padLeft(2, '0')}:00',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.text),
            ),
          ),
          _btn(c, '+', value < max ? () => onChange(value + 1) : null),
        ],
      ),
    );
  }

  Widget _btn(AppColors c, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: onTap != null ? c.accentBright : c.text3,
          ),
        ),
      ),
    );
  }
}
