import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/store.dart';
import '../widgets/sheet.dart';
import 'appointment_form.dart';
import 'customer_form.dart';
import 'service_form.dart';

/// Bequeme Öffner für die Formular-Sheets.
void openAppointmentForm(
  BuildContext context,
  AppStore store, {
  Appointment? initial,
  String? defaultDate,
  String? defaultTime,
  String? presetCustomerId,
  bool showDelete = true,
}) {
  showAppSheet(
    context: context,
    title: initial != null ? 'Termin bearbeiten' : 'Neuer Termin',
    builder: (_) => AppointmentForm(
      store: store,
      initial: initial,
      defaultDate: defaultDate,
      defaultTime: defaultTime,
      presetCustomerId: presetCustomerId,
      showDelete: showDelete,
    ),
  );
}

void openCustomerForm(
  BuildContext context,
  AppStore store, {
  Customer? initial,
  VoidCallback? onDeleted,
}) {
  showAppSheet(
    context: context,
    title: initial != null ? 'Kunde bearbeiten' : 'Neuer Kunde',
    builder: (_) => CustomerForm(store: store, initial: initial, onDeleted: onDeleted),
  );
}

void openServiceForm(BuildContext context, AppStore store, {Service? initial}) {
  showAppSheet(
    context: context,
    title: initial != null ? 'Leistung bearbeiten' : 'Neue Leistung',
    builder: (_) => ServiceForm(store: store, initial: initial),
  );
}
