import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DataGridStyles {
  static ThemeData getCustomDataGridTheme() {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        color: Colors.blue,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static GridColumn buildDataColumn(String columnName, String label) {
    return GridColumn(
      columnName: columnName,
      label: Container(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8FA),
        
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      width: 120,
    );
  }
}
