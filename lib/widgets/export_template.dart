import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:io';
import 'package:open_file/open_file.dart';

class ExcelTemplateDownloader {
  static Future<void> downloadExcelTemplate(BuildContext context) async {
    // Create a new workbook and access the first worksheet.
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    // Set the column headers for the Excel template.
    sheet.getRangeByName('A1').setText('First Name');
    sheet.getRangeByName('B1').setText('Last Name');
    sheet.getRangeByName('C1').setText('Date of Birth');
    sheet.getRangeByName('D1').setText('ID Number');
    sheet.getRangeByName('E1').setText('Body Number');
    sheet.getRangeByName('F1').setText('Address');
    sheet.getRangeByName('G1').setText('Mobile Number');
    sheet.getRangeByName('H1').setText('Email');
    sheet.getRangeByName('I1').setText('Tag');

    // Auto-fit all columns.
    for (int col = 1; col <= 9; col++) {
      sheet.autoFitColumn(col);
    }

    // Save the workbook as a byte stream.
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      // Handle file download for web platforms.
      AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Driver_Template.xlsx')
        ..click();
    } else {
      // Handle file saving and opening for mobile and desktop platforms.
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = Platform.isWindows
          ? '$path\\Driver_Template.xlsx'
          : '$path/Driver_Template.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(file.path);
    }

    // Show a confirmation message.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel template downloaded.'),
      ),
    );
  }
}
