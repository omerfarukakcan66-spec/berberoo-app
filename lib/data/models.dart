/// Barberoo — Datenmodelle. Felder & Defaults exakt wie im JS-Store.

class Service {
  String id;
  String name;
  int duration; // Minuten
  double price; // Euro

  Service({required this.id, required this.name, this.duration = 30, this.price = 0});

  factory Service.fromJson(Map<String, dynamic> j) => Service(
        id: j['id'],
        name: j['name'] ?? '',
        duration: (j['duration'] ?? 30).toInt(),
        price: (j['price'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'duration': duration, 'price': price};

  Service clone() => Service.fromJson(toJson());
}

class Customer {
  String id;
  String name;
  String phone;
  String email;
  String haarfarbe;
  String allergien;
  String vorlieben;
  String notiz;

  Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.haarfarbe = '',
    this.allergien = '',
    this.vorlieben = '',
    this.notiz = '',
  });

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'],
        name: j['name'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
        haarfarbe: j['haarfarbe'] ?? '',
        allergien: j['allergien'] ?? '',
        vorlieben: j['vorlieben'] ?? '',
        notiz: j['notiz'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'haarfarbe': haarfarbe,
        'allergien': allergien,
        'vorlieben': vorlieben,
        'notiz': notiz,
      };

  Customer clone() => Customer.fromJson(toJson());

  /// Hat eine relevante Allergie (nicht leer / nicht "keine").
  bool get hasAllergy {
    final a = allergien.trim().toLowerCase();
    return a.isNotEmpty && a != 'keine';
  }
}

class Appointment {
  String id;
  String customerId;
  String serviceId;
  String serviceName;
  String date; // ISO "yyyy-MM-dd"
  String time; // "HH:mm"
  int duration;
  double price;
  String notiz;
  String pay; // offen | bezahlt | spaeter | nicht
  bool done; // abgeschlossen — verschwindet aus Heutige Termine

  Appointment({
    required this.id,
    this.customerId = '',
    this.serviceId = '',
    this.serviceName = '',
    required this.date,
    this.time = '10:00',
    this.duration = 30,
    this.price = 0,
    this.notiz = '',
    this.pay = 'offen',
    this.done = false,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        id: j['id'],
        customerId: j['customerId'] ?? '',
        serviceId: j['serviceId'] ?? '',
        serviceName: j['serviceName'] ?? '',
        date: j['date'],
        time: j['time'] ?? '10:00',
        duration: (j['duration'] ?? 30).toInt(),
        price: (j['price'] ?? 0).toDouble(),
        notiz: j['notiz'] ?? '',
        pay: j['pay'] ?? 'offen',
        done: j['done'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'date': date,
        'time': time,
        'duration': duration,
        'price': price,
        'notiz': notiz,
        'pay': pay,
        'done': done,
      };

  Appointment clone() => Appointment.fromJson(toJson());
}

class Todo {
  String id;
  String text;
  bool done;

  Todo({required this.id, required this.text, this.done = false});

  factory Todo.fromJson(Map<String, dynamic> j) =>
      Todo(id: j['id'], text: j['text'] ?? '', done: j['done'] ?? false);

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'done': done};
}
