import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';

class DriverDataSource extends DataGridSource {
  DriverDataSource(this.source, this.onRowTapped) {
    _buildDataGridRows();
  }

  final List<DriversAccount> source;
  final void Function(DriversAccount) onRowTapped;
  List<DataGridRow> dataGridRows = [];

  void _buildDataGridRows() {
    dataGridRows = source.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'firstName', value: data.firstName),
        DataGridCell<String>(columnName: 'lastName', value: data.lastName),
        DataGridCell<String>(columnName: 'idNumber', value: data.idNumber),
        DataGridCell<String>(columnName: 'bodyNumber', value: data.bodyNumber),
        DataGridCell<String>(columnName: 'tag', value: data.tag),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return GestureDetector(
          onTap: () {
            final index = dataGridRows.indexOf(row);
            if (index != -1) {
              onRowTapped(source[index]);
            }
          },
          child: Center(child: Text(cell.value.toString())),
        );
      }).toList(),
    );
  }
}
