import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../data/models.dart';
import '../data/store.dart';
import '../data/date_utils.dart';
import '../data/payment.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import '../widgets/inputs.dart';
import '../widgets/rows.dart';
import '../widgets/press_scale.dart';
import '../widgets/toast.dart';

/// Terminformular — Portierung von AppointmentForm (forms.jsx).
class AppointmentForm extends StatefulWidget {
  final AppStore store;
  final Appointment? initial;
  final String? defaultDate;
  final String? defaultTime;
  final String? presetCustomerId;
  final bool showDelete;

  const AppointmentForm({
    super.key,
    required this.store,
    this.initial,
    this.defaultDate,
    this.defaultTime,
    this.presetCustomerId,
    this.showDelete = true,
  });

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  late String customerId;
  late String serviceId;
  late String date;
  late String time;
  late TextEditingController _dur;
  late TextEditingController _price;
  late TextEditingController _notiz;
  late String pay;
  String err = '';

  Appointment? get base => widget.initial;

  @override
  void initState() {
    super.initState();
    final b = widget.initial;
    customerId = b?.customerId ?? widget.presetCustomerId ?? '';
    serviceId = b?.serviceId ?? '';
    date = b?.date ?? widget.defaultDate ?? D.todayISO();
    time = b?.time ?? widget.defaultTime ?? '10:00';
    _dur = TextEditingController(text: (b?.duration ?? 30).toString());
    _price = TextEditingController(text: _fmtNum(b?.price ?? 0));
    _notiz = TextEditingController(text: b?.notiz ?? '');
    pay = b?.pay ?? 'offen';
  }

  @override
  void dispose() {
    _dur.dispose();
    _price.dispose();
    _notiz.dispose();
    super.dispose();
  }

  String _fmtNum(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  void _pickService(Service s) {
    setState(() {
      serviceId = s.id;
      _dur.text = s.duration.toString();
      _price.text = _fmtNum(s.price);
    });
  }

  void _submit() {
    if (customerId.isEmpty) {
      setState(() => err = 'Bitte einen Kunden wählen.');
      return;
    }
    if (serviceId.isEmpty) {
      setState(() => err = 'Bitte eine Leistung wählen.');
      return;
    }
    final svc = widget.store.services.firstWhere((s) => s.id == serviceId,
        orElse: () => Service(id: '', name: ''));
    final a = Appointment(
      id: base?.id ?? D.uid(),
      customerId: customerId,
      serviceId: serviceId,
      serviceName: svc.name,
      date: date,
      time: time,
      duration: int.tryParse(_dur.text) ?? 0,
      price: double.tryParse(_price.text.replaceAll(',', '.')) ?? 0,
      notiz: _notiz.text.trim(),
      pay: pay,
    );
    widget.store.saveAppt(a);
    Toast.show(context, base != null ? 'Termin gespeichert' : 'Termin angelegt');
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final init = D.parseISO(date);
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(data: Theme.of(context), child: child!),
    );
    if (picked != null) setState(() => date = D.iso(picked));
  }

  Future<void> _pickTime() async {
    final parts = time.split(':').map(int.parse).toList();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: parts[0], minute: parts[1]),
      builder: (ctx, child) =>
          MediaQuery(data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (picked != null) {
      setState(() => time = '${D.pad(picked.hour)}:${D.pad(picked.minute)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final store = widget.store;
    final services = store.services;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kunde
        AppField(
          label: 'Kunde',
          child: _CustomerPicker(
            store: store,
            value: customerId,
            onChange: (id) => setState(() => customerId = id),
          ),
        ),
        // Dienstleistung
        AppField(
          label: 'Dienstleistung',
          child: services.isEmpty
              ? Text('Erst Leistungen anlegen (Tab „Leistungen“).',
                  style: TextStyle(fontSize: 13, color: c.text2))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in services)
                      ChoiceChipX(
                        label: s.name,
                        sub: '${D.euro(s.price)} € · ${s.duration} min',
                        active: serviceId == s.id,
                        onTap: () => _pickService(s),
                      ),
                  ],
                ),
        ),
        // Datum + Uhrzeit
        Row(
          children: [
            Expanded(
              child: AppField(
                label: 'Datum',
                child: _PickerField(text: D.fmtLong(date), onTap: _pickDate),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppField(
                label: 'Uhrzeit',
                child: _PickerField(text: '$time Uhr', onTap: _pickTime),
              ),
            ),
          ],
        ),
        // Dauer + Preis
        Row(
          children: [
            Expanded(
              child: AppField(
                label: 'Dauer (Min.)',
                child: AppTextField(
                  controller: _dur,
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppField(
                label: 'Preis (€)',
                child: AppTextField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                ),
              ),
            ),
          ],
        ),
        // Notiz
        AppField(
          label: 'Notiz',
          child: AppTextField(
            controller: _notiz,
            hint: 'z. B. besondere Wünsche …',
            minLines: 3,
            maxLines: 5,
          ),
        ),
        // Status
        const LabelText('Status / Bezahlung', margin: EdgeInsets.fromLTRB(2, 4, 2, 10)),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3.6,
          children: [
            for (final k in kPayOrder) _payOption(k),
          ],
        ),
        const SizedBox(height: 16),
        if (err.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
            child: Text(err, style: TextStyle(color: c.danger, fontSize: 13)),
          ),
        AppButton(base != null ? 'Speichern' : 'Termin anlegen',
            variant: BtnVariant.primary, onTap: _submit),
        if (base != null) ...[
          const SizedBox(height: 16),
          _AbschlussSection(
            currentPay: pay,
            onAbschliessen: (selectedPay) {
              final a = Appointment(
                id: base!.id,
                customerId: customerId,
                serviceId: serviceId,
                serviceName: widget.store.services
                    .firstWhere((s) => s.id == serviceId,
                        orElse: () => Service(id: '', name: ''))
                    .name,
                date: date,
                time: time,
                duration: int.tryParse(_dur.text) ?? 0,
                price: double.tryParse(_price.text.replaceAll(',', '.')) ?? 0,
                notiz: _notiz.text.trim(),
                pay: selectedPay,
                done: true,
              );
              widget.store.saveAppt(a);
              Toast.show(context, 'Termin abgeschlossen');
              Navigator.of(context).pop();
            },
          ),
        ],
        if (base != null && widget.showDelete) ...[
          const SizedBox(height: 10),
          AppButton('Termin löschen',
              icon: 'trash',
              variant: BtnVariant.danger, onTap: () {
            widget.store.deleteAppt(base!.id);
            Toast.show(context, 'Termin gelöscht');
            Navigator.of(context).pop();
          }),
        ],
      ],
    );
  }

  Widget _payOption(String k) {
    final c = context.c;
    final m = payMeta(k, c);
    final active = pay == k;
    return PressScale(
      onTap: () => setState(() => pay = k),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: active ? c.surface3 : c.surface2,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: active ? m.color : c.line, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 11,
              height: 11,
              margin: const EdgeInsets.only(right: 9),
              decoration: BoxDecoration(color: m.dot, shape: BoxShape.circle),
            ),
            Expanded(
              child: Text(m.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: active ? m.color : c.text2)),
            ),
          ],
        ),
      ),
    );
  }
}

/// .selectish als Auslöser für Datum/Uhrzeit-Picker
class _PickerField extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PickerField({required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PressScale(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: c.line),
        ),
        alignment: Alignment.centerLeft,
        child: Text(text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15, color: c.text)),
      ),
    );
  }
}

/// Inline-Kundenauswahl mit Suche + Schnellanlage (CustomerPicker).
class _CustomerPicker extends StatefulWidget {
  final AppStore store;
  final String value;
  final ValueChanged<String> onChange;
  const _CustomerPicker({required this.store, required this.value, required this.onChange});

  @override
  State<_CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends State<_CustomerPicker> {
  bool open = false;
  final _q = TextEditingController();
  final _newName = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    _newName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final customers = widget.store.customers;
    final sel = customers.where((x) => x.id == widget.value).cast<Customer?>().firstWhere(
          (x) => true,
          orElse: () => null,
        );

    if (!open) {
      return PressScale(
        onTap: () => setState(() => open = true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(sel?.name ?? 'Kunde wählen …',
                    style: TextStyle(fontSize: 16, color: sel != null ? c.text : c.text3)),
              ),
              Transform.rotate(
                angle: 1.5708,
                child: AppIcon('chevron', size: 18, color: c.text3),
              ),
            ],
          ),
        ),
      );
    }

    final list = customers.where((x) => x.name.toLowerCase().contains(_q.text.toLowerCase())).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: c.line),
      ),
      child: Column(
        children: [
          SearchField(
            controller: _q,
            hint: 'Suchen …',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: list.isEmpty && _q.text.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text('Noch keine Kunden.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: c.text2)),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final cu = list[i];
                      return PressScale(
                        onTap: () {
                          widget.onChange(cu.id);
                          setState(() => open = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: c.line),
                          ),
                          child: Row(
                            children: [
                              Avatar(name: cu.name),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(cu.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15.5,
                                        color: c.text)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: c.line),
          ),
          Row(
            children: [
              Expanded(
                child: AppTextField(controller: _newName, hint: 'Neuer Kunde – Name'),
              ),
              const SizedBox(width: 8),
              PressScale(
                onTap: () {
                  final name = _newName.text.trim();
                  if (name.isNotEmpty) {
                    final id = widget.store.quickCustomer(name);
                    widget.onChange(id);
                    setState(() {
                      open = false;
                      _newName.clear();
                    });
                  }
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('Anlegen',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AbschlussSection extends StatefulWidget {
  final String currentPay;
  final ValueChanged<String> onAbschliessen;
  const _AbschlussSection({required this.currentPay, required this.onAbschliessen});

  @override
  State<_AbschlussSection> createState() => _AbschlussSectionState();
}

class _AbschlussSectionState extends State<_AbschlussSection> {
  late String _pay;

  @override
  void initState() {
    super.initState();
    _pay = widget.currentPay == 'offen' ? 'bezahlt' : widget.currentPay;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    const bg = Color(0xFFAD5840);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bg.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TERMIN ABSCHLIESSEN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.14 * 11,
              color: bg,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.6,
            children: [
              for (final k in kPayOrder)
                _payChip(context, c, k),
            ],
          ),
          const SizedBox(height: 12),
          PressScale(
            onTap: () => widget.onAbschliessen(_pay),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Abgeschlossen',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payChip(BuildContext context, AppColors c, String k) {
    final m = payMeta(k, c);
    final active = _pay == k;
    return PressScale(
      onTap: () => setState(() => _pay = k),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? c.surface3 : c.surface2,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: active ? m.color : c.line, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: m.dot, shape: BoxShape.circle),
            ),
            Expanded(
              child: Text(
                m.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: active ? m.color : c.text2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
