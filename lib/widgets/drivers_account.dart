class DriversAccount {
  final String driverId;
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
  final String driverPhotos;
  final String role;
  final String deviceToken;
  final String uid;

  DriversAccount({
    required this.driverId,
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
    required this.driverPhotos,
    required this.role,
    required this.deviceToken,
    required this.uid,
  });

  factory DriversAccount.fromJson(Map<String, dynamic> json) {
    return DriversAccount(
      uid: json['uid'] ?? '',
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
      driverPhotos: json['driverPhotos'] ?? '',
      role: json['role'] ?? '', // Added role
      deviceToken: json['deviceToken'] ?? '', // Added deviceToken
      driverId: json['driverId'] ?? '', // Added driverId
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
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
      'driverPhotos': driverPhotos,
      'role': role,
      'deviceToken': deviceToken,
      'driverId': driverId,
    };
  }
}
