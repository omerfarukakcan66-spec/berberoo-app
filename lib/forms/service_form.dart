import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../data/models.dart';
import '../data/store.dart';
import '../data/date_utils.dart';
import '../widgets/common.dart';
import '../widgets/inputs.dart';
import '../widgets/toast.dart';

/// Leistungsformular — Portierung von ServiceForm (forms.jsx).
class ServiceForm extends StatefulWidget {
  final AppStore store;
  final Service? initial;
  const ServiceForm({super.key, required this.store, this.initial});

  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _dur = TextEditingController(text: (widget.initial?.duration ?? 30).toString());
  late final _price = TextEditingController(text: _fmtNum(widget.initial?.price ?? 0));
  String err = '';

  Service? get base => widget.initial;

  String _fmtNum(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _name.dispose();
    _dur.dispose();
    _price.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      setState(() => err = 'Bitte einen Namen eingeben.');
      return;
    }
    widget.store.saveService(Service(
      id: base?.id ?? D.uid(),
      name: _name.text.trim(),
      duration: int.tryParse(_dur.text) ?? 0,
      price: double.tryParse(_price.text.replaceAll(',', '.')) ?? 0,
    ));
    Toast.show(context, 'Leistung gespeichert');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppField(
          label: 'Name',
          child: AppTextField(
              controller: _name, hint: 'z. B. Herrenschnitt', autofocus: base == null),
        ),
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
        if (err.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
            child: Text(err, style: TextStyle(color: c.danger, fontSize: 13)),
          ),
        AppButton(base != null ? 'Speichern' : 'Leistung anlegen',
            variant: BtnVariant.primary, onTap: _submit),
        if (base != null) ...[
          const SizedBox(height: 10),
          AppButton('Leistung löschen', icon: 'trash', variant: BtnVariant.danger, onTap: () {
            widget.store.deleteService(base!.id);
            Toast.show(context, 'Leistung gelöscht');
            Navigator.of(context).pop();
          }),
        ],
      ],
    );
  }
}
