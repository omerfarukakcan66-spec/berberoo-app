import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../data/store.dart';
import '../data/date_utils.dart';
import '../widgets/common.dart';
import '../widgets/app_icon.dart';
import '../widgets/press_scale.dart';
import '../forms/open_forms.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'customers_screen.dart';
import 'services_screen.dart';
import 'todos_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String view = 'heute';
  String? customerDetailId;

  static const _nav = [
    ['heute', 'Heute', 'home'],
    ['kalender', 'Kalender', 'calendar'],
    ['kunden', 'Kunden', 'users'],
    ['leistungen', 'Leistungen', 'scissors'],
    ['aufgaben', 'Aufgaben', 'check'],
  ];

  void _setView(String v) {
    setState(() {
      view = v;
      if (v != 'kunden') customerDetailId = null;
    });
  }

  void _fabAction(AppStore store) {
    switch (view) {
      case 'kunden':
        openCustomerForm(context, store);
        break;
      case 'leistungen':
        openServiceForm(context, store);
        break;
      default:
        openAppointmentForm(context, store, defaultDate: D.todayISO(), defaultTime: '10:00');
    }
  }

  ({String title, String eyebrow}) _titles(AppStore store) {
    switch (view) {
      case 'kalender':
        return (title: 'Kalender', eyebrow: 'Übersicht');
      case 'kunden':
        return (title: 'Kunden', eyebrow: '${store.customers.length} gespeichert');
      case 'leistungen':
        return (title: 'Leistungen', eyebrow: 'Preisliste');
      case 'aufgaben':
        return (title: 'Aufgaben', eyebrow: 'Merkzettel');
      default:
        return (title: 'Heute', eyebrow: D.fmtRel(D.todayISO()));
    }
  }

  Widget _activeScreen(AppStore store) {
    switch (view) {
      case 'kalender':
        return CalendarScreen(store: store);
      case 'kunden':
        return CustomersScreen(
          store: store,
          detailId: customerDetailId,
          onSelect: (id) => setState(() => customerDetailId = id),
          onBack: () => setState(() => customerDetailId = null),
        );
      case 'leistungen':
        return ServicesScreen(store: store);
      case 'aufgaben':
        return TodosScreen(store: store);
      default:
        return DashboardScreen(store: store);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final store = context.watch<AppStore>();
    final th = _titles(store);
    final showFab = view != 'aufgaben' && !(view == 'kunden' && customerDetailId != null);

    return Scaffold(
      backgroundColor: c.shellBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Dim.appMax),
          child: DecoratedBox(
            decoration: BoxDecoration(color: c.bg),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _appbar(context, store, th),
                  Expanded(
                    child: Stack(
                      children: [
                        // scrollbarer Screen-Bereich
                        Positioned.fill(
                          child: SingleChildScrollView(
                            key: ValueKey('$view${customerDetailId ?? ''}'),
                            padding: EdgeInsets.fromLTRB(18, 4, 18, Dim.navH + 28),
                            child: _activeScreen(store),
                          ),
                        ),
                        // FAB
                        if (showFab)
                          Positioned(
                            right: 18,
                            bottom: 18,
                            child: PressScale(
                              onTap: () => _fabAction(store),
                              scale: 0.93,
                              child: Container(
                                width: 60,
                                height: 60,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: c.accent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: c.accent.withOpacity(0.45),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: AppIcon('plus', size: 28, strokeWidth: 2.2, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _bottomNav(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appbar(BuildContext context, AppStore store, ({String title, String eyebrow}) th) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      color: c.bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                    ),
                    Text(store.salon,
                        style: AppFonts.serif(TextStyle(fontSize: 24, color: c.text, height: 1))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(th.title,
                    style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.02 * 27,
                        height: 1.05,
                        color: c.text)),
                const SizedBox(height: 3),
                Text(th.eyebrow, style: TextStyle(fontSize: 14, color: c.text2)),
              ],
            ),
          ),
          IconBtn('gear',
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ],
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    final c = context.c;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(6, 8, 6, 8 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: c.surface.withOpacity(0.86),
            border: Border(top: BorderSide(color: c.line)),
          ),
          child: Row(
            children: [
              for (final n in _nav)
                Expanded(
                  child: _NavBtn(
                    icon: n[2],
                    label: n[1],
                    active: view == n[0],
                    onTap: () => _setView(n[0]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavBtn(
      {required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = active ? c.accentBright : c.text3;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icon, size: 23, strokeWidth: 1.9, color: color),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: active ? c.accentBright : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
