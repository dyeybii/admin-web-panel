import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Appstyle {
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
      GoogleFonts.poppins(fontSize: 25.0, fontWeight: FontWeight.bold);

  static TextStyle dateTitle =
      GoogleFonts.poppins(fontSize: 15.0, fontWeight: FontWeight.normal);

  static TextStyle mainContent =
      GoogleFonts.poppins(fontSize: 18.0, fontWeight: FontWeight.w500);
}

class CustomButtonStyles {
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: const Color(0xFF2E3192),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}

class FareTableStyle {
  static final TextStyle headerTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );

  static final TextStyle cellTextStyle = TextStyle(
    fontWeight: FontWeight.normal,
  );

  static final TextStyle textFieldLabelStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );
}

Color get specialColor {
  return Color(0xFF2E3192); // Return the desired color
}

Map<int, Color> color = {
  50: Color.fromRGBO(46, 49, 146, .1),
  100: Color.fromRGBO(46, 49, 146, .2),
  200: Color.fromRGBO(46, 49, 146, .3),
  300: Color.fromRGBO(46, 49, 146, .4),
  400: Color.fromRGBO(46, 49, 146, .5),
  500: Color.fromRGBO(46, 49, 146, .6),
  600: Color.fromRGBO(46, 49, 146, .7),
  700: Color.fromRGBO(46, 49, 146, .8),
  800: Color.fromRGBO(46, 49, 146, .9),
  900: Color.fromRGBO(46, 49, 146, 1),
};
MaterialColor customColor = MaterialColor(0xFF2E3192, color);
