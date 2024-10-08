class TotalRatings {
  final double averageRating;
  final int ratingCount;
  final int ratingSum;

  TotalRatings({
    required this.averageRating,
    required this.ratingCount,
    required this.ratingSum,
  });

  factory TotalRatings.fromJson(Map<String, dynamic> json) {
    return TotalRatings(
      averageRating: (json['averageRating'] as num).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      ratingSum: json['ratingSum'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'ratingSum': ratingSum,
    };
  }
}

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
  final String tag;
  final String driverPhoto;
  final String uid;
  final TotalRatings? totalRatings;
  final String? currentTripID;
  final String? deviceToken;

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
    required this.tag,
    required this.driverPhoto,
    required this.uid,
    this.totalRatings,
    this.currentTripID,
    this.deviceToken,
  });

  static DriversAccount? fromJson(Map<dynamic, dynamic> json) {

    if (json['firstName'] == null || (json['firstName'] as String).isEmpty) {
      return null; 
    }

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
      tag: json['tag'] ?? '',
      driverPhoto: json['driverPhoto'] ?? '',
      driverId: json['driverId'] ?? '',
      totalRatings: json['totalRatings'] != null
          ? TotalRatings.fromJson(Map<String, dynamic>.from(json['totalRatings']))
          : null,
      currentTripID: json['currentTripID'],
      deviceToken: json['deviceToken'],
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
      'tag': tag,
      'driverPhoto': driverPhoto,
      'driverId': driverId,
      if (totalRatings != null) 'totalRatings': totalRatings!.toJson(),
      if (currentTripID != null) 'currentTripID': currentTripID,
      if (deviceToken != null) 'deviceToken': deviceToken,
    };
  }
}
