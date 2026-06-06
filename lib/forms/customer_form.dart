import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/models.dart';
import '../data/store.dart';
import '../data/date_utils.dart';
import '../widgets/common.dart';
import '../widgets/inputs.dart';
import '../widgets/toast.dart';

/// Kundenformular — Portierung von CustomerForm (forms.jsx).
class CustomerForm extends StatefulWidget {
  final AppStore store;
  final Customer? initial;
  final VoidCallback? onDeleted;
  const CustomerForm({super.key, required this.store, this.initial, this.onDeleted});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _phone = TextEditingController(text: widget.initial?.phone ?? '');
  late final _email = TextEditingController(text: widget.initial?.email ?? '');
  late final _haar = TextEditingController(text: widget.initial?.haarfarbe ?? '');
  late final _allerg = TextEditingController(text: widget.initial?.allergien ?? '');
  late final _vor = TextEditingController(text: widget.initial?.vorlieben ?? '');
  late final _notiz = TextEditingController(text: widget.initial?.notiz ?? '');
  String err = '';

  Customer? get base => widget.initial;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _haar, _allerg, _vor, _notiz]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      setState(() => err = 'Bitte einen Namen eingeben.');
      return;
    }
    widget.store.saveCustomer(Customer(
      id: base?.id ?? D.uid(),
      name: _name.text.trim(),
      phone: _phone.text,
      email: _email.text,
      haarfarbe: _haar.text,
      allergien: _allerg.text,
      vorlieben: _vor.text,
      notiz: _notiz.text,
    ));
    Toast.show(context, 'Kunde gespeichert');
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
              controller: _name, hint: 'Vor- und Nachname', autofocus: base == null),
        ),
        Row(
          children: [
            Expanded(
              child: AppField(
                label: 'Telefon',
                child: AppTextField(
                    controller: _phone, hint: '0170 …', keyboardType: TextInputType.phone),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppField(
                label: 'E-Mail',
                child: AppTextField(
                    controller: _email,
                    hint: 'optional',
                    keyboardType: TextInputType.emailAddress),
              ),
            ),
          ],
        ),
        const LabelText('Steckbrief', margin: EdgeInsets.fromLTRB(2, 16, 2, 10)),
        Row(
          children: [
            Expanded(
              child: AppField(
                label: 'Haarfarbe',
                child: AppTextField(controller: _haar, hint: 'z. B. Aschblond'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppField(
                label: 'Allergien',
                child: AppTextField(controller: _allerg, hint: 'z. B. keine'),
              ),
            ),
          ],
        ),
        AppField(
          label: 'Vorlieben / Lieblingsschnitt',
          child: AppTextField(
              controller: _vor, hint: 'z. B. Bob, kürzerer Pony …', minLines: 2, maxLines: 4),
        ),
        AppField(
          label: 'Notizen',
          child: AppTextField(
              controller: _notiz, hint: 'Sonstiges …', minLines: 2, maxLines: 4),
        ),
        if (err.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
            child: Text(err, style: TextStyle(color: c.danger, fontSize: 13)),
          ),
        AppButton(base != null ? 'Speichern' : 'Kunde anlegen',
            variant: BtnVariant.primary, onTap: _submit),
        if (base != null) ...[
          const SizedBox(height: 10),
          AppButton('Kunde löschen', icon: 'trash', variant: BtnVariant.danger, onTap: () {
            widget.store.deleteCustomer(base!.id);
            Toast.show(context, 'Kunde gelöscht');
            Navigator.of(context).pop();
            widget.onDeleted?.call();
          }),
        ],
      ],
    );
  }
}
