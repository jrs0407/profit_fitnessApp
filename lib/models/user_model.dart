class UserModel {
  final String name;
  final String surname;
  String? email;
  String? password;
  String? phone;
  DateTime? birthdate;

  int nivel;
  int xp;
  List<String> metodoPago;
  String ultimosDigitosTarjeta;

  bool trainer;
  bool admin;

  UserModel({
    required this.name,
    required this.surname,
    this.email,
    this.password,
    this.phone,
    this.birthdate,
    this.nivel = 1,
    this.xp = 0,
    this.metodoPago = const ['Tarjeta de crédito'],
    this.ultimosDigitosTarjeta = '',
    this.trainer = false,
    this.admin = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': name,
      'apellidos': surname,
      'email': email ?? '',
      'telefono': phone ?? '',
      'fechaNacimiento': birthdate,
      'premium': false,
      'nivel': nivel,
      'xp': xp,
      'metodoPago': metodoPago,
      'ultimosDigitosTarjeta': ultimosDigitosTarjeta,
      'trainer': trainer,
      'admin': admin,
    };
  }
}
