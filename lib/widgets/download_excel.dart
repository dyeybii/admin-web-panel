import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:io';
import 'package:open_file/open_file.dart';

class ExcelDownloader {

  static Future<void> downloadExcel(
      BuildContext context, List<DriversAccount> allDrivers, List<DriversAccount> selectedDrivers) async {
 
    List<DriversAccount> driversToDownload = selectedDrivers.isNotEmpty ? selectedDrivers : allDrivers;


    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1').setText('First Name');
    sheet.getRangeByName('B1').setText('Last Name');
    sheet.getRangeByName('C1').setText('Date of Birth');
    sheet.getRangeByName('D1').setText('ID Number');
    sheet.getRangeByName('E1').setText('Body Number');
    sheet.getRangeByName('F1').setText('Address');
    sheet.getRangeByName('G1').setText('Mobile Number');
    sheet.getRangeByName('H1').setText('Email');
    sheet.getRangeByName('I1').setText('Tag');

 
    int row = 2;
    for (var driver in driversToDownload) {
      sheet.getRangeByIndex(row, 1).setText(driver.firstName);
      sheet.getRangeByIndex(row, 2).setText(driver.lastName);
      sheet.getRangeByIndex(row, 3).setText(driver.birthdate);
      sheet.getRangeByIndex(row, 4).setText(driver.idNumber);
      sheet.getRangeByIndex(row, 5).setText(driver.bodyNumber);
      sheet.getRangeByIndex(row, 6).setText(driver.address);
      sheet.getRangeByIndex(row, 7).setText(driver.phoneNumber);
      sheet.getRangeByIndex(row, 8).setText(driver.email);
      sheet.getRangeByIndex(row, 9).setText(driver.tag);
      row++;
    }


    for (int col = 1; col <= 9; col++) {
      sheet.autoFitColumn(col);
    }


    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {

      AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Drivers Information.xlsx')
        ..click();
    } else {

      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName =
          Platform.isWindows ? '$path\\Drivers Information.xlsx' : '$path/drivers_data.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(file.path);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel file downloaded.'),
      ),
    );
  }
}
