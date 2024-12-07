import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:open_file/open_file.dart';

class ExcelTemplateDownloader {
  static Future<void> downloadExcelTemplate(BuildContext context) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('Driver Template.xlsx');

      if (kIsWeb) {
        final downloadUrl = await storageRef.getDownloadURL();
        AnchorElement(href: downloadUrl)
          ..setAttribute('download', 'Driver Template.xlsx')
          ..click();
      } else {
        final String path = (await getApplicationSupportDirectory()).path;
        final String filePath = Platform.isWindows ? '$path\\Driver Template.xlsx' : '$path/Driver Template.xlsx';
        final File file = File(filePath);

        final downloadTask = storageRef.writeToFile(file);
        await downloadTask;

        OpenFile.open(file.path);
      }

      // Success message with custom styling
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBarStyles.info('Excel template downloaded from Firebase Storage.'),
      );
    } catch (e) {
      // Error message with custom styling
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBarStyles.error('Failed to download Excel template: $e'),
      );
    }
  }
}
