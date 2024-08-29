class DriversAccount {
  final String uid;
  final String driverId; // New property
  final String firstName;
  final String lastName;
  final String idNumber;
  final String bodyNumber;
  final String email;
  final String birthdate;
  final String address;
  final String phoneNumber;
  final String codingScheme;
  final String tag;
  final String driver_photos;
  final String role;
   // New property

  DriversAccount({
    required this.uid,
    required this.driverId, // Updated constructor
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.bodyNumber,
    required this.email,
    required this.birthdate,
    required this.address,
    required this.phoneNumber,
    required this.codingScheme,
    required this.tag,
    required this.driver_photos, // Updated constructor
    required this.role,
  });

  factory DriversAccount.fromJson(Map<String, dynamic> json) {
    return DriversAccount(
      uid: json['id'] ?? '',
      driverId: json['driverId'] ?? '', // Updated factory method
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      idNumber: json['idNumber'] ?? '',
      bodyNumber: json['bodyNumber'] ?? '',
      email: json['email'] ?? '',
      birthdate: json['birthdate'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      codingScheme: json['codingScheme'] ?? '',
      tag: json['tag'] ?? '',
      driver_photos: json['driver_photos'] ?? '', // Updated factory method
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'driverId': driverId, // Updated toJson method
      'firstName': firstName,
      'lastName': lastName,
      'idNumber': idNumber,
      'bodyNumber': bodyNumber,
      'email': email,
      'birthdate': birthdate,
      'address': address,
      'phoneNumber': phoneNumber,
      'codingScheme': codingScheme,
      'tag': tag,
      'driver_photos': driver_photos, // Updated toJson method
    };
  }
}
