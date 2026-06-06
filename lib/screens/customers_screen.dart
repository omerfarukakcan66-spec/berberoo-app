import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../data/store.dart';
import '../data/models.dart';
import '../data/date_utils.dart';
import '../widgets/common.dart';
import '../widgets/rows.dart';
import '../widgets/inputs.dart';
import '../widgets/press_scale.dart';
import '../widgets/app_icon.dart';
import '../forms/open_forms.dart';

class CustomersScreen extends StatefulWidget {
  final AppStore store;
  final String? detailId;
  final ValueChanged<String> onSelect;
  final VoidCallback onBack;
  const CustomersScreen({
    super.key,
    required this.store,
    required this.detailId,
    required this.onSelect,
    required this.onBack,
  });

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _q = TextEditingController();

  AppStore get store => widget.store;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detailansicht
    if (widget.detailId != null) {
      final c = store.customerById(widget.detailId!);
      if (c != null) {
        return _CustomerDetail(store: store, customer: c, onBack: widget.onBack);
      }
    }

    final list = store.customers
        .where((c) => ('${c.name} ${c.phone}').toLowerCase().contains(_q.text.toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchField(
          controller: _q,
          hint: 'Kunde suchen …',
          onChanged: (_) => setState(() {}),
          onClear: () => setState(() => _q.clear()),
        ),
        const SizedBox(height: 14),
        LabelText('${list.length} ${list.length == 1 ? 'Kunde' : 'Kunden'}',
            margin: const EdgeInsets.fromLTRB(2, 2, 2, 10)),
        if (list.isEmpty)
          EmptyState(
            icon: 'users',
            text: _q.text.isNotEmpty
                ? 'Niemand gefunden.'
                : 'Noch keine Kunden. Tippe auf + zum Anlegen.',
          )
        else
          Column(
            children: [
              for (final c in list) ...[
                ListRow(
                  leading: Avatar(name: c.name),
                  title: c.name,
                  subtitle: c.phone.isNotEmpty
                      ? c.phone
                      : (c.email.isNotEmpty ? c.email : 'keine Kontaktdaten'),
                  trailing: c.hasAllergy
                      ? Pill('⚠',
                          fg: context.c.warn,
                          bg: context.c.warnSoft,
                          border: Colors.transparent)
                      : null,
                  onTap: () => widget.onSelect(c.id),
                ),
                if (c != list.last) const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }
}

/// Kundendetail mit Steckbrief & Verlauf (CustomerDetail).
class _CustomerDetail extends StatelessWidget {
  final AppStore store;
  final Customer customer;
  final VoidCallback onBack;
  const _CustomerDetail({required this.store, required this.customer, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final today = D.todayISO();
    final cu = customer;
    final history = store.appts.where((a) => a.customerId == cu.id).toList()
      ..sort((a, b) => (b.date + b.time).compareTo(a.date + a.time));
    final past = history.where((a) => a.date.compareTo(today) <= 0).toList();
    final upcoming = history.where((a) => a.date.compareTo(today) > 0).toList();
    final totalSpent =
        history.where((a) => a.date.compareTo(today) <= 0).fold<double>(0, (s, a) => s + a.price);
    final visits = history.where((a) => a.date.compareTo(today) <= 0).length;

    void edit() => openCustomerForm(context, store, initial: cu, onDeleted: onBack);
    void book() => openAppointmentForm(context, store,
        defaultDate: today, defaultTime: '10:00', presetCustomerId: cu.id, showDelete: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: IconBtn('arrowL', iconSize: 20, onTap: onBack),
          ),
        ),
        // Hero
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 18),
          child: Column(
            children: [
              Avatar(name: cu.name, size: 76),
              const SizedBox(height: 12),
              Text(cu.name,
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: c.text)),
              if (cu.hasAllergy) ...[
                const SizedBox(height: 8),
                Pill('⚠ Allergie: ${cu.allergien}',
                    fg: c.warn, bg: c.warnSoft, border: Colors.transparent),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (cu.phone.isNotEmpty)
                    _ContactBtn(icon: 'phone', onTap: () => _launch('tel:${cu.phone.replaceAll(' ', '')}')),
                  if (cu.email.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    _ContactBtn(icon: 'mail', onTap: () => _launch('mailto:${cu.email}')),
                  ],
                  const SizedBox(width: 10),
                  _ContactBtn(icon: 'edit', onTap: edit),
                ],
              ),
            ],
          ),
        ),
        // Stats
        Row(
          children: [
            Expanded(child: _MiniStat(label: 'Besuche', value: '$visits')),
            const SizedBox(width: 12),
            Expanded(
                child: _MiniStat(
                    label: 'Umsatz gesamt', value: D.euro(totalSpent), currency: true)),
          ],
        ),
        // Steckbrief
        const SectionTitle('Steckbrief'),
        _NoteGrid(cu: cu),
        // Kommende Termine
        if (upcoming.isNotEmpty) ...[
          const SectionTitle('Kommende Termine'),
          Column(
            children: [
              for (final a in upcoming.reversed) ...[
                _historyTile(context, a),
                if (a != upcoming.reversed.last) const SizedBox(height: 10),
              ],
            ],
          ),
        ],
        // Verlauf
        const SectionTitle('Verlauf'),
        if (past.isEmpty)
          const EmptyState(icon: 'clock', text: 'Noch keine vergangenen Termine.')
        else
          Column(
            children: [
              for (final a in past) ...[
                _historyTile(context, a),
                if (a != past.last) const SizedBox(height: 10),
              ],
            ],
          ),
        const SizedBox(height: 16),
        AppButton('Termin buchen', icon: 'plus', variant: BtnVariant.primary, onTap: book),
        const SizedBox(height: 10),
        AppButton('Kunde bearbeiten', icon: 'edit', variant: BtnVariant.ghost, onTap: edit),
      ],
    );
  }

  ApptTile _historyTile(BuildContext context, Appointment a) {
    return ApptTile(
      timeTop: D.fmtShort(a.date),
      timeTopSize: 13,
      timeBottom: a.time,
      who: a.serviceName,
      what: '${D.parseISO(a.date).year}',
      pay: a.pay,
      priceLabel: '${D.euro(a.price)} €',
      onTap: () => openAppointmentForm(context, store, initial: a),
    );
  }

  Future<void> _launch(String uri) async {
    final u = Uri.parse(uri);
    if (await canLaunchUrl(u)) await launchUrl(u);
  }
}

class _ContactBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _ContactBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PressScale(
      onTap: onTap,
      scale: 0.94,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: c.line),
        ),
        child: AppIcon(icon, size: 20, color: c.text),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final bool currency;
  const _MiniStat({required this.label, required this.value, this.currency = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(R.md),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelText(label),
          const SizedBox(height: 8),
          currency
              ? RichText(
                  text: TextSpan(
                    style: AppFonts.serif(TextStyle(fontSize: 34, height: 1, color: c.text)),
                    children: [
                      TextSpan(text: '€ ', style: TextStyle(fontSize: 19, color: c.text2)),
                      TextSpan(text: value),
                    ],
                  ),
                )
              : Text(value,
                  style: AppFonts.serif(TextStyle(fontSize: 34, height: 1, color: c.text))),
        ],
      ),
    );
  }
}

class _NoteGrid extends StatelessWidget {
  final Customer cu;
  const _NoteGrid({required this.cu});

  @override
  Widget build(BuildContext context) {
    Widget card(String label, String val, {bool full = false}) {
      final c = context.c;
      final w = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelText(label),
            const SizedBox(height: 5),
            Text(val.isNotEmpty ? val : '—',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: val.isNotEmpty ? FontWeight.w600 : FontWeight.w400,
                    fontStyle: val.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                    color: val.isNotEmpty ? c.text : c.text3)),
          ],
        ),
      );
      return w;
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: card('Telefon', cu.phone)),
            const SizedBox(width: 10),
            Expanded(child: card('E-Mail', cu.email)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: card('Haarfarbe', cu.haarfarbe)),
            const SizedBox(width: 10),
            Expanded(child: card('Allergien', cu.allergien)),
          ],
        ),
        const SizedBox(height: 10),
        card('Vorlieben / Lieblingsschnitt', cu.vorlieben, full: true),
        const SizedBox(height: 10),
        card('Notizen', cu.notiz, full: true),
      ],
    );
  }
}
