import 'package:admin_web_panel/Style/data_grid_styles.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DriverTable extends StatefulWidget {
  final List<DriversAccount> driversAccountList;

  const DriverTable({Key? key, required this.driversAccountList})
      : super(key: key);

  @override
  _DriverTableState createState() => _DriverTableState();
}

class _DriverTableState extends State<DriverTable> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _deleteData(DriversAccount data) async {
    try {
      // Delete data from Firestore
      QuerySnapshot querySnapshot = await _firestore.collection('DriversAccount')
          .where('firstName', isEqualTo: data.firstName)
          .where('lastName', isEqualTo: data.lastName)
          .where('idNumber', isEqualTo: data.idNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await _firestore.collection('DriversAccount').doc(querySnapshot.docs.first.id).delete();

        // Delete user from Firebase Authentication
        User? user = await _auth.currentUser;
        if (user != null) {
          await user.delete();
          print('User deleted from Firebase Authentication');
        } else {
          print('User not found in Firebase Authentication');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data deleted successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data not found'),
          ),
        );
      }
    } catch (e) {
      print('Error deleting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting data: $e'),
        ),
      );
    }
  }

  void _editData(Map<String, dynamic> data) {
    // Dito functionality ng Edit
    print('Editing data: $data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfDataGrid(
        source: _DriverDataSource(widget.driversAccountList, _deleteData, _editData, context),
        columns: <GridColumn>[
          DataGridStyles.buildDataColumn('firstName', 'First Name'),
          DataGridStyles.buildDataColumn('lastName', 'Last Name'),
          DataGridStyles.buildDataColumn('idNumber', 'ID Number'),
          DataGridStyles.buildDataColumn('bodyNumber', 'Body Number'),
          DataGridStyles.buildDataColumn('email', 'Email'),
          DataGridStyles.buildDataColumn('birthdate', 'Date of Birth'),
          DataGridStyles.buildDataColumn('address', 'Address'),
          DataGridStyles.buildDataColumn('emergencyContact', 'Contact #'),
          DataGridStyles.buildDataColumn('codingScheme', 'Coding Scheme'),
          DataGridStyles.buildDataColumn('tag', 'Tag'),
          GridColumn(
            columnName: 'Actions',
            width: 100,
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Actions'),
            ),
          ),
        ],
        columnWidthMode: ColumnWidthMode.lastColumnFill,
        gridLinesVisibility: GridLinesVisibility.none,
        headerGridLinesVisibility: GridLinesVisibility.none,
        headerRowHeight: 60,
      ),
    );
  }
}

class _DriverDataSource extends DataGridSource {
  _DriverDataSource(this.source, this.deleteData, this.editData, this.context) {
    _buildDataGridRows();
  }

  final List<DriversAccount> source;
  final Function(DriversAccount) deleteData;
  final Function(Map<String, dynamic>) editData;
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];

  void _buildDataGridRows() {
    dataGridRows = source.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        _buildDataCell('firstName', data.firstName),
        _buildDataCell('lastName', data.lastName),
        _buildDataCell('idNumber', data.idNumber),
        _buildDataCell('bodyNumber', data.bodyNumber),
        _buildDataCell('email', data.email),
        _buildDataCell('birthdate', data.birthdate),
        _buildDataCell('address', data.address),
        _buildDataCell('emergencyContact', data.emergencyContact),
        _buildDataCell('codingScheme', data.codingScheme),
        _buildDataCell('tag', data.tag),
        _buildActionCell(data, context),
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

  DataGridCell<Widget> _buildActionCell(DriversAccount data, BuildContext context) {
    return DataGridCell<Widget>(
      columnName: 'Actions',
      value: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(data, context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              editData(data.toJson());
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(DriversAccount data, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this data?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('This action cannot be undone. Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmDelete == true) {
                  deleteData(data);
                  
                  source.removeWhere((d) => d.firstName == data.firstName && d.lastName == data.lastName && d.idNumber == data.idNumber);
                  _buildDataGridRows();
                  notifyListeners();
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
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