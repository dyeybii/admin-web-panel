import 'package:admin_web_panel/widgets/data_grid_styles.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DriverTable extends StatelessWidget {
  final List<DriversAccount> driversAccountList;

  const DriverTable({Key? key, required this.driversAccountList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Data Table'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('DriversAccount').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Map<String, dynamic>> data = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return SfDataGrid(
            source: _DriverDataSource(data),
            columns: <GridColumn>[
              DataGridStyles.buildDataColumn('firstName', 'First Name'),
              DataGridStyles.buildDataColumn('lastName', 'Last Name'),
              DataGridStyles.buildDataColumn('idNumber', 'ID Number'),
              DataGridStyles.buildDataColumn('bodyNumber', 'Body Number'),
              DataGridStyles.buildDataColumn('email', 'Email'),
              DataGridStyles.buildDataColumn('birthdate', 'date of birth'),
              DataGridStyles.buildDataColumn('address', 'Address'),
              DataGridStyles.buildDataColumn(
                  'emergencyContact', 'Contact #'),
              DataGridStyles.buildDataColumn('codingScheme', 'Coding Scheme'),
              DataGridStyles.buildDataColumn('tag', 'Tag'),
            ],
            columnWidthMode: ColumnWidthMode.lastColumnFill,
            gridLinesVisibility: GridLinesVisibility.none,
            headerGridLinesVisibility: GridLinesVisibility.none,
            headerRowHeight: 60,
          );
        },
      ),
    );
  }
}

class _DriverDataSource extends DataGridSource {
  _DriverDataSource(this.source) {
    _buildDataGridRows();
  }

  final List<Map<String, dynamic>> source;
  List<DataGridRow> dataGridRows = [];

  void _buildDataGridRows() {
    dataGridRows = source.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        _buildDataCell('firstName', data['firstName']),
        _buildDataCell('lastName', data['lastName']),
        _buildDataCell('idNumber', data['idNumber']),
        _buildDataCell('bodyNumber', data['bodyNumber']),
        _buildDataCell('email', data['email']),
        _buildDataCell('birthdate', data['birthdate']),
        _buildDataCell('address', data['address']),
        _buildDataCell('emergencyContact', data['emergencyContact']),
        _buildDataCell('codingScheme', data['codingScheme']),
        _buildDataCell('tag', data['tag']),
      ]);
    }).toList();
  }

  DataGridCell<Widget> _buildDataCell(String columnName, dynamic value) {
    return DataGridCell<Widget>(
      columnName: columnName,
      value: Center(
        child: Text(value.toString()),
      ),
    );
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return Center(
          child: cell.value as Widget,
        );
      }).toList(),
    );
  }
}
