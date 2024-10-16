import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class Appstyle{
  static Color bgColor = const Color(0xFFe2e2ff);
  static Color mainColor = const Color(0xFF000633);
  static Color accentColor = const Color(0xFF0065FF);
  static List<Color> cardsColor = [
    Colors.red.shade100,
    Colors.pink.shade100,
    Colors.orange.shade100,
    Colors.yellow.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.blueGrey.shade100,
Colors.blueGrey.shade100,
  ];


  static TextStyle mainTitle = 
          GoogleFonts.poppins(fontSize: 25.0,fontWeight:FontWeight .bold);

  
  static TextStyle dateTitle = 
          GoogleFonts.poppins(fontSize: 15.0,fontWeight:FontWeight .normal); 

  static TextStyle mainContent = 
          GoogleFonts.poppins(fontSize: 18.0,fontWeight:FontWeight .w500);
}


class CustomButtonStyles {
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white, backgroundColor: const Color(0xFF2E3192), // Text color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}