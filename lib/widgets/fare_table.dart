import 'package:flutter/material.dart';

class Fare {
  final String from;
  final String to;
  final double distance;
  final double minimumFare;
  final int special;

  Fare({
    required this.from,
    required this.to,
    required this.distance,
    required this.minimumFare,
    required this.special,
  });

  // Method to determine color based on special value
  Color get specialColor {
    // You can customize the color logic based on the special value
    return const Color(0xFF2E3192);
  }
}


final List<Fare> fareTable = [
  Fare(from: 'Cotoda Terminal Malanday via Coloong I', to: 'Sanfranciso Street.', distance: 1.03, minimumFare: 11.5, special: 46),
  Fare(from: '', to: 'Coloong Health Center', distance: 1.87, minimumFare: 11.5, special: 46),
  Fare(from: '', to: 'San Migual II ST.', distance: 2.56, minimumFare: 13, special: 52),
  Fare(from: '', to: 'Hulo (C.PASCUAL ST.)', distance: 3.52, minimumFare: 14.5, special: 58),
  Fare(from: '', to: 'Pangkera', distance: 3.46, minimumFare: 14.5, special: 58),
  Fare(from: 'Cotoda Terminal Malanday via Coloong II', to: 'Tindahan ng bibingka', distance: 1.15, minimumFare: 11.5, special: 46),
  Fare(from: '', to: 'Coloong Health Center', distance: 2.15, minimumFare: 13, special: 52),
  Fare(from: '', to: 'San Migual II ST.', distance: 2.98, minimumFare: 13, special: 52),
  Fare(from: '', to: 'Hulo (C.PASCUAL ST.)', distance: 3.78, minimumFare: 14.5, special: 58),
  Fare(from: '', to: 'Pangkera', distance: 3.98, minimumFare: 14.5, special: 58),
  Fare(from: 'Cotoda Terminal Malanday via Coloong I', to: 'Heartville Subdivision', distance: 1.34, minimumFare: 11.5, special: 46),
  Fare(from: '', to: 'Coloong Health Center', distance: 2.16, minimumFare: 13, special: 52),
  Fare(from: '', to: 'San Migual II ST.', distance: 2.87, minimumFare: 13, special: 52),
  Fare(from: '', to: 'Hulo', distance: 3.81, minimumFare: 14.5, special: 58),
  Fare(from: '', to: 'Pangkera', distance: 3.75, minimumFare: 14.5, special: 58),
  Fare(from: 'Cotoda Terminal Malanday via Coloong II', to: 'Bernardo ST.', distance: 1.04, minimumFare: 11.5, special: 46),
  Fare(from: '', to: 'Coloong Health Center', distance: 1.85, minimumFare: 11.5, special: 46),
  Fare(from: '', to: 'San Migual II ST.', distance: 2.67, minimumFare: 13, special: 52),
  Fare(from: '', to: 'Hulo', distance: 3.48, minimumFare: 14.5, special: 58),
  Fare(from: '', to: 'Pangkera', distance: 3.68, minimumFare: 14.5, special: 58),
];
