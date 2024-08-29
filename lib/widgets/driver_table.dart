import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_web_panel/Style/data_grid_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

class DriverTable extends StatefulWidget {
  final List<DriversAccount> driversAccountList;

  const DriverTable({Key? key, required this.driversAccountList})
      : super(key: key);

  @override
  _DriverTableState createState() => _DriverTableState();
}

class _DriverTableState extends State<DriverTable> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfDataGrid(
        source: _DriverDataSource(widget.driversAccountList, context),
        columns: <GridColumn>[
          DataGridStyles.buildDataColumn('firstName', 'First Name'),
          DataGridStyles.buildDataColumn('lastName', 'Last Name'),
          DataGridStyles.buildDataColumn('idNumber', 'ID Number'),
          DataGridStyles.buildDataColumn('bodyNumber', 'Body Number'),
          DataGridStyles.buildDataColumn('tag', 'Tag'),
        ],
        columnWidthMode: ColumnWidthMode.lastColumnFill,
        gridLinesVisibility: GridLinesVisibility.none,
        headerGridLinesVisibility: GridLinesVisibility.none,
        headerRowHeight: 60,
        onCellTap: (DataGridCellTapDetails details) {
          if (details.rowColumnIndex.rowIndex != 0) {
            final driver =
                widget.driversAccountList[details.rowColumnIndex.rowIndex - 1];
            _showDriverDetailsDialog(driver, context);
          }
        },
      ),
    );
  }

  void _showDriverDetailsDialog(DriversAccount driver, BuildContext context) {
    TextEditingController firstNameController =
        TextEditingController(text: driver.firstName);
    TextEditingController lastNameController =
        TextEditingController(text: driver.lastName);
    TextEditingController idNumberController =
        TextEditingController(text: driver.idNumber);
    TextEditingController bodyNumberController =
        TextEditingController(text: driver.bodyNumber);
    TextEditingController emailController =
        TextEditingController(text: driver.email);
    TextEditingController birthdateController =
        TextEditingController(text: driver.birthdate);
    TextEditingController addressController =
        TextEditingController(text: driver.address);
    TextEditingController phoneNumberController =
        TextEditingController(text: driver.phoneNumber);
    TextEditingController codingSchemeController =
        TextEditingController(text: driver.codingScheme);
    TextEditingController tagController =
        TextEditingController(text: driver.tag);
    TextEditingController driver_photosController =
        TextEditingController(text: driver.driver_photos);

    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          driver_photosController.text = pickedFile.path;
        });
      }
    }

    void _updateDriverData() async {
      try {
        await _firestore
            .collection('DriversAccount')
            .doc(driver.driverId)
            .update({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'idNumber': idNumberController.text,
          'bodyNumber': bodyNumberController.text,
          'email': emailController.text,
          'birthdate': birthdateController.text,
          'address': addressController.text,
          'phoneNumber': phoneNumberController.text,
          'codingScheme': codingSchemeController.text,
          'tag': tagController.text,
          'driver_photos': driver_photosController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data updated successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating data: $e')),
        );
      }
    }

    void _deleteDriverData() async {
      try {
        await _firestore
            .collection('DriversAccount')
            .doc(driver.driverId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Personal Information'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: driver.driver_photos.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: driver.driver_photos,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Image.asset('images/default_avatar.png'),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              )
                            : Image.asset(
                                'images/default_avatar.png',
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _pickImage,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Form(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableTextField(
                                'First Name', firstNameController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEditableTextField(
                                'Last Name', lastNameController),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableTextField(
                                'ID Number', idNumberController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEditableTextField(
                                'Body Number', bodyNumberController),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableTextField(
                                'Email', emailController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEditableTextField(
                                'Date of Birth', birthdateController),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableTextField(
                                'Address', addressController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEditableTextField('Tag', tagController),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableTextField('phoneNumberController',
                                phoneNumberController),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildEditableTextField(
                                'Coding Scheme', codingSchemeController),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _deleteDriverData,
              child: const Text('Delete Account'),
            ),
            ElevatedButton(
              onPressed: _updateDriverData,
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableTextField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

class _DriverDataSource extends DataGridSource {
  _DriverDataSource(this.source, this.context) {
    _buildDataGridRows();
  }

  final List<DriversAccount> source;
  final BuildContext context;
  List<DataGridRow> dataGridRows = [];

  void _buildDataGridRows() {
    dataGridRows = source.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        _buildDataCell('firstName', data.firstName),
        _buildDataCell('lastName', data.lastName),
        _buildDataCell('idNumber', data.idNumber),
        _buildDataCell('bodyNumber', data.bodyNumber),
        _buildDataCell('tag', data.tag),
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
