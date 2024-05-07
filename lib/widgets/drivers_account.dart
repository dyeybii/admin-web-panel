class DriversAccount {
  final String id;
  final String firstName;
  final String lastName;
  final String idNumber;
  final String bodyNumber;
  final String email;
  final String birthdate;
  final String address;
  final String emergencyContact;
  final String codingScheme;
  final String tag;

  DriversAccount({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.bodyNumber,
    required this.email,
    required this.birthdate,
    required this.address,
    required this.emergencyContact,
    required this.codingScheme,
    required this.tag,
  });

  factory DriversAccount.fromJson(Map<String, dynamic> json) {
    return DriversAccount(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      idNumber: json['idNumber'] ?? '',
      bodyNumber: json['bodyNumber'] ?? '',
      email: json['email'] ?? '',
      birthdate: json['birthdate'] ?? '',
      address: json['address'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
      codingScheme: json['codingScheme'] ?? '',
      tag: json['tag'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'idNumber': idNumber,
      'bodyNumber': bodyNumber,
      'email': email,
      'birthdate': birthdate,
      'address': address,
      'emergencyContact': emergencyContact,
      'codingScheme': codingScheme,
      'tag': tag,
    };
  }
}