import 'package:admin_web_panel/responsive/drivers_page_desktop.dart';
import 'package:admin_web_panel/responsive/drivers_page_mobile.dart';
import 'package:flutter/material.dart';


class DriversPage extends StatelessWidget {
  static const String id = "/webPageDrivers";

  const DriversPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return const DriversPageMobile();
        } else {
          return const DriversPageDesktop();
        }
      },
    );
  }
}
