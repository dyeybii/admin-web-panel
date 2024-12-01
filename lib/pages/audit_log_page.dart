import 'package:admin_web_panel/responsive/audit_log_desktop.dart';
import 'package:admin_web_panel/responsive/audit_log_mobile.dart';
import 'package:flutter/material.dart';


class AuditLogPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to determine the screen size and conditionally render the appropriate page
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check the screen width and decide which version of the page to display
        if (constraints.maxWidth > 600) {
          return const AuditLogPageDesktop();  // Show desktop version for larger screens
        } else {
          return const AuditLogPageMobile();  // Show mobile version for smaller screens
        }
      },
    );
  }
}
