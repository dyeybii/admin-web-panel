import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DriverTable extends StatelessWidget {
   final List<DriversAccount> driversAccountList;

  const DriverTable({Key? key, required this.driversAccountList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Data Table'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('DriversAccount').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final List<Map<String, dynamic>> data = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

          return SfDataGrid(
            source: _DriverDataSource(data),
            columns: <GridColumn>[
              _buildDataColumn('firstName', 'First Name'),
              _buildDataColumn('lastName', 'Last Name'),
              _buildDataColumn('idNumber', 'ID Number'),
              _buildDataColumn('bodyNumber', 'Body Number'),
              _buildDataColumn('email', 'Email'),
              _buildDataColumn('birthdate', 'Birthdate'),
              _buildDataColumn('address', 'Address'),
              _buildDataColumn('emergencyContact', 'Emergency Contact'),
            ],
          );
        },
      ),
    );
  }

  GridColumn _buildDataColumn(String columnName, String label) {
    return GridColumn(
      columnName: columnName,
      label: Container(
        padding: EdgeInsets.all(20.0),
        alignment: Alignment.centerLeft,
        child: Text(label),
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
      ]);
    }).toList();
  }

  DataGridCell<Widget> _buildDataCell(String columnName, dynamic value) {
    return DataGridCell<Widget>(columnName: columnName, value: Text(value.toString()));
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return cell.value as Widget; // Extracting the value as a Widget
      }).toList(),
    );
  }
}
