import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'date_utils.dart';

/// Barberoo — zentraler Datenspeicher. Portierung von store.js.
/// Hält Leistungen, Kunden, Termine, Aufgaben; speichert in shared_preferences.
class AppStore extends ChangeNotifier {
  static const _key = 'barberoo_v1';

  List<Service> services = [];
  List<Customer> customers = [];
  List<Appointment> appts = [];
  List<Todo> todos = [];
  String salon = 'Barberoo';
  bool seeded = false;
  int workStart = 9;  // Arbeitszeit Beginn (Stunde)
  int workEnd = 18;   // Arbeitszeit Ende (Stunde)

  late SharedPreferences _prefs;

  /// Beim App-Start aufrufen.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_key);
    if (raw != null) {
      try {
        _applyJson(jsonDecode(raw));
      } catch (_) {
        _applyEmpty();
        await _save();
      }
    } else {
      _applyEmpty(); // Erststart: leer, ohne Beispieldaten
      await _save();
    }
    notifyListeners();
  }

  // ---------------- Laden / Speichern ----------------
  void _applyJson(Map<String, dynamic> j) {
    services = (j['services'] as List? ?? []).map((e) => Service.fromJson(e)).toList();
    customers = (j['customers'] as List? ?? []).map((e) => Customer.fromJson(e)).toList();
    appts = (j['appts'] as List? ?? []).map((e) => Appointment.fromJson(e)).toList();
    todos = (j['todos'] as List? ?? []).map((e) => Todo.fromJson(e)).toList();
    salon = j['salon'] ?? 'Barberoo';
    seeded = j['seeded'] ?? false;
    workStart = j['workStart'] ?? 9;
    workEnd = j['workEnd'] ?? 18;
  }

  Map<String, dynamic> _toJson() => {
        'services': services.map((e) => e.toJson()).toList(),
        'customers': customers.map((e) => e.toJson()).toList(),
        'appts': appts.map((e) => e.toJson()).toList(),
        'todos': todos.map((e) => e.toJson()).toList(),
        'salon': salon,
        'seeded': seeded,
        'workStart': workStart,
        'workEnd': workEnd,
      };

  Future<void> _save() async => _prefs.setString(_key, jsonEncode(_toJson()));

  void _commit() {
    _save();
    notifyListeners();
  }

  // ---------------- Lookups ----------------
  String custName(String id) =>
      customers.firstWhere((c) => c.id == id, orElse: () => Customer(id: '', name: 'Unbekannt')).name;

  Customer? customerById(String id) {
    for (final c in customers) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ---------------- Aktionen: Termine ----------------
  void saveAppt(Appointment a) {
    final i = appts.indexWhere((x) => x.id == a.id);
    if (i >= 0) {
      appts[i] = a;
    } else {
      appts.add(a);
    }
    _commit();
  }

  void deleteAppt(String id) {
    appts.removeWhere((x) => x.id == id);
    _commit();
  }

  // ---------------- Aktionen: Kunden ----------------
  void saveCustomer(Customer c) {
    final i = customers.indexWhere((x) => x.id == c.id);
    if (i >= 0) {
      customers[i] = c;
    } else {
      customers.add(c);
    }
    _commit();
  }

  void deleteCustomer(String id) {
    customers.removeWhere((x) => x.id == id);
    _commit();
  }

  String quickCustomer(String name) {
    final id = D.uid();
    customers.add(Customer(id: id, name: name));
    _commit();
    return id;
  }

  // ---------------- Aktionen: Leistungen ----------------
  void saveService(Service s) {
    final i = services.indexWhere((x) => x.id == s.id);
    if (i >= 0) {
      services[i] = s;
    } else {
      services.add(s);
    }
    _commit();
  }

  void deleteService(String id) {
    services.removeWhere((x) => x.id == id);
    _commit();
  }

  // ---------------- Aktionen: Aufgaben ----------------
  void addTodo(String text) {
    todos.insert(0, Todo(id: D.uid(), text: text));
    _commit();
  }

  void toggleTodo(String id) {
    final t = todos.firstWhere((x) => x.id == id, orElse: () => Todo(id: '', text: ''));
    if (t.id.isNotEmpty) t.done = !t.done;
    _commit();
  }

  void deleteTodo(String id) {
    todos.removeWhere((x) => x.id == id);
    _commit();
  }

  void clearDoneTodos() {
    todos.removeWhere((x) => x.done);
    _commit();
  }

  // ---------------- Salon-Name ----------------
  void setSalon(String name) {
    salon = name.trim().isEmpty ? 'Barberoo' : name.trim();
    _commit();
  }

  void setWorkHours(int start, int end) {
    workStart = start.clamp(0, 23);
    workEnd = end.clamp(1, 24);
    _commit();
  }

  // ---------------- Daten setzen ----------------
  void loadDemo() {
    _applyDemo();
    _commit();
  }

  void clearAll() {
    _applyEmpty();
    _commit();
  }

  /// Alle Daten als JSON-String exportieren.
  String exportJson() => jsonEncode(_toJson());

  /// Daten aus JSON-String importieren. Gibt Fehlertext zurück oder null bei Erfolg.
  String? importJson(String raw) {
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      _applyJson(j);
      _commit();
      return null;
    } catch (e) {
      return 'Ungültige Datei: $e';
    }
  }

  void _applyEmpty() {
    services = [];
    customers = [];
    appts = [];
    todos = [];
    salon = 'Barberoo';
    seeded = false;
  }

  // ---------------- Beispieldaten (1:1 aus store.js) ----------------
  void _applyDemo() {
    final t = D.todayISO();
    services = [
      Service(id: 's1', name: 'Herrenschnitt', duration: 30, price: 28),
      Service(id: 's2', name: 'Damenschnitt', duration: 60, price: 48),
      Service(id: 's3', name: 'Waschen & Föhnen', duration: 30, price: 22),
      Service(id: 's4', name: 'Färben', duration: 90, price: 75),
      Service(id: 's5', name: 'Strähnen', duration: 120, price: 95),
      Service(id: 's6', name: 'Bart & Konturen', duration: 20, price: 18),
      Service(id: 's7', name: 'Kinderschnitt', duration: 20, price: 16),
    ];
    customers = [
      Customer(id: 'c1', name: 'Lena Hofmann', phone: '0176 2233445', email: 'lena.h@mail.de', haarfarbe: 'Aschblond', allergien: 'keine', vorlieben: 'Lieblingsschnitt: Bob, mag kürzeren Pony', notiz: 'Kommt meist samstags. Trinkt Espresso.'),
      Customer(id: 'c2', name: 'Markus Reiter', phone: '0151 9988776', email: 'm.reiter@web.de', haarfarbe: 'Naturbraun', allergien: 'Ammoniak', vorlieben: 'Maschine 3 an den Seiten', notiz: 'Kein Gerede, mag es ruhig.'),
      Customer(id: 'c3', name: 'Sophie Brand', phone: '0170 5566778', email: 'sophie.brand@gmx.de', haarfarbe: 'Kupferrot (gefärbt)', allergien: 'keine', vorlieben: 'Strähnen warm, nichts zu hell', notiz: 'Termin am liebsten nachmittags.'),
      Customer(id: 'c4', name: 'Daniel Köhler', phone: '0162 3344556', email: '', haarfarbe: 'Dunkelblond', allergien: 'keine', vorlieben: 'Bart immer mitmachen', notiz: ''),
      Customer(id: 'c5', name: 'Aylin Yıldız', phone: '0177 1122334', email: 'aylin.y@mail.de', haarfarbe: 'Schwarz', allergien: 'PPD (Haarfarbe)', vorlieben: 'Nur ammoniakfreie Produkte!', notiz: 'Wichtig: Allergie beachten.'),
      Customer(id: 'c6', name: 'Thomas Wagner', phone: '0151 4455667', email: '', haarfarbe: 'Grau meliert', allergien: 'keine', vorlieben: 'Klassisch, Seitenscheitel', notiz: ''),
    ];

    Appointment mk(String customerId, String serviceId, String date, String time, String notiz) {
      final s = services.firstWhere((x) => x.id == serviceId);
      final past = date.compareTo(D.todayISO()) < 0;
      return Appointment(
        id: D.uid(),
        customerId: customerId,
        serviceId: serviceId,
        serviceName: s.name,
        date: date,
        time: time,
        duration: s.duration,
        price: s.price,
        notiz: notiz,
        pay: past ? 'bezahlt' : 'offen',
      );
    }

    appts = [
      // heute
      mk('c1', 's2', t, '09:00', 'Bitte etwas kürzer als letztes Mal.'),
      mk('c4', 's1', t, '10:30', ''),
      mk('c5', 's3', t, '11:30', 'Ammoniakfreie Produkte!'),
      mk('c3', 's5', t, '13:30', ''),
      mk('c6', 's1', t, '16:00', ''),
      // restliche Woche
      mk('c2', 's1', D.addDays(t, 1), '09:30', ''),
      mk('c1', 's3', D.addDays(t, 1), '14:00', ''),
      mk('c3', 's4', D.addDays(t, 2), '10:00', 'Kupferton auffrischen'),
      mk('c6', 's6', D.addDays(t, 2), '15:30', ''),
      mk('c4', 's1', D.addDays(t, 3), '11:00', ''),
      mk('c5', 's2', D.addDays(t, 4), '13:00', ''),
      // Verlauf
      mk('c1', 's2', D.addDays(t, -7), '09:00', ''),
      mk('c1', 's3', D.addDays(t, -28), '10:00', ''),
      mk('c2', 's1', D.addDays(t, -14), '16:30', ''),
      mk('c3', 's5', D.addDays(t, -35), '13:00', ''),
      mk('c6', 's1', D.addDays(t, -21), '16:00', ''),
    ];
    // etwas Abwechslung beim Status für die Demo
    if (appts.isNotEmpty) appts[0].pay = 'bezahlt';
    if (appts.length > 2) appts[2].pay = 'spaeter';
    if (appts.length > 12) appts[12].pay = 'nicht';

    todos = [
      Todo(id: 't1', text: 'Färbemittel Kupfer nachbestellen'),
      Todo(id: 't2', text: 'Handtücher zur Wäscherei bringen'),
      Todo(id: 't3', text: 'Sophie wegen Termin zurückrufen', done: true),
      Todo(id: 't4', text: 'Schaufenster-Deko erneuern'),
    ];
    salon = 'Barberoo';
    seeded = true;
  }
}
