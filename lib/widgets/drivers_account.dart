class DriversAccount {
  final String address;
  final String birthdate;
  final String bodyNumber;
  final String email;
  final String emergencyContact;
  final String firstName;
  final String idNumber;
  final String lastName;
  final String codingScheme;
  final String tag;

  DriversAccount({
    required this.address,
    required this.birthdate,
    required this.bodyNumber,
    required this.email,
    required this.emergencyContact,
    required this.firstName,
    required this.idNumber,
    required this.lastName,
    required this.codingScheme,
    required this.tag,
  });

  factory DriversAccount.fromJson(Map<String, dynamic> json) {
    return DriversAccount(
      address: json['address'] ?? '',
      birthdate: json['birthdate'] ?? '',
      bodyNumber: json['bodyNumber'] ?? '',
      email: json['email'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
      firstName: json['firstName'] ?? '',
      idNumber: json['idNumber'] ?? '',
      lastName: json['lastName'] ?? '',
      codingScheme: json['codingScheme'] ?? '',
      tag: json['tag'] ?? '',
    );
  }
}
