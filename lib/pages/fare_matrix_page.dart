import 'package:admin_web_panel/Data_service.dart';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/widgets/fare_table.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FareMatrixPage extends StatefulWidget {
  static const String id = "webPageDriverManagement";

  const FareMatrixPage({Key? key}) : super(key: key);

  @override
  _FareMatrixPageState createState() => _FareMatrixPageState();
}

class _FareMatrixPageState extends State<FareMatrixPage> {
  final TextEditingController basefareController = TextEditingController();
  final TextEditingController addedkmController = TextEditingController();
  final TextEditingController totalfareFareController = TextEditingController();
  final DataService _dataService = DataService();

  bool isEditing = false;
  late DocumentSnapshot currentParameters;

  @override
  void initState() {
    super.initState();
    _loadFareParameters();
  }

  Future<void> _loadFareParameters() async {
    try {
      DocumentSnapshot doc = await _dataService.getFareParameters();

      setState(() {
        currentParameters = doc;
        basefareController.text = doc['baseFareAmount'].toString();
        addedkmController.text = doc['distancePerKmAmount'].toString();
        totalfareFareController.text =
            doc['durationPerMinuteAmount'].toString();
      });
    } catch (e) {
      print('Error loading fare parameters: $e');
    }
  }

  Future<void> _saveFareParameters() async {
    try {
      await _dataService.saveFareParameters(
        baseFare: double.parse(basefareController.text),
        distancePerKm: double.parse(addedkmController.text),
        durationPerMinute: double.parse(totalfareFareController.text),
      );

      setState(() {
        isEditing = false;
      });
    } catch (e) {
      print('Error saving fare parameters: $e');
    }
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _cancelEdit() {
    setState(() {
      isEditing = false;

      basefareController.text = currentParameters['baseFareAmount'].toString();
      addedkmController.text =
          currentParameters['distancePerKmAmount'].toString();
      totalfareFareController.text =
          currentParameters['durationPerMinuteAmount'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF2E3192);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Fare Matrix"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildFareMatrixContainer(primaryColor),
                const SizedBox(height: 30),
                _buildFareTableContainer(primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFareMatrixContainer(Color primaryColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerWidth =
            constraints.maxWidth < 600 ? constraints.maxWidth : 600;
        return Container(
          width: containerWidth,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Fare Matrix in COTODA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF2E3192),
                ),
              ),
              const SizedBox(height: 15),
              _buildTextFormField(
                controller: basefareController,
                label: 'Base Fare amount',
                enabled: isEditing,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                controller: addedkmController,
                label: 'Distance added per kilometer amount',
                enabled: isEditing,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                controller: totalfareFareController,
                label: 'Duration per minute amount',
                enabled: isEditing,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isEditing)
                    ElevatedButton(
                      onPressed: _toggleEditMode,
                      style: CustomButtonStyles.elevatedButtonStyle,
                      child: const Text('Change Fare'),
                    ),
                  if (isEditing) ...[
                    ElevatedButton(
                      onPressed: _saveFareParameters,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Save changes'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _cancelEdit,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFareTableContainer(Color primaryColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2E3192), 
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Fare Table',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF2E3192), 
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20.0,
                  headingRowHeight: 56.0,
                  dataRowMinHeight: 48.0,
                  dataRowMaxHeight: 60.0,
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        'From',
                        style: FareTableStyle.headerTextStyle.copyWith(
                          color: const Color(
                              0xFF2E3192),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'To',
                        style: FareTableStyle.headerTextStyle.copyWith(
                          color: const Color(
                              0xFF2E3192), 
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Distance',
                        style: FareTableStyle.headerTextStyle.copyWith(
                          color: const Color(
                              0xFF2E3192), 
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Special',
                        style: FareTableStyle.headerTextStyle.copyWith(
                          color: const Color(
                              0xFF2E3192), 
                        ),
                      ),
                    ),
                  ],
                  rows: fareTable.map((fare) {
                    return DataRow(cells: [
                      DataCell(Text(
                        fare.from.isEmpty ? ' ' : fare.from,
                        style: FareTableStyle.cellTextStyle.copyWith(
                          color:
                              const Color(0xFF2E3192),
                        ),
                      )),
                      DataCell(Text(
                        fare.to,
                        style: FareTableStyle.cellTextStyle.copyWith(
                          color: const Color(0xFF2E3192), 
                        ),
                      )),
                      DataCell(Text(
                        '${fare.distance} km',
                        style: FareTableStyle.cellTextStyle.copyWith(
                          color: const Color(
                              0xFF2E3192), 
                        ),
                      )),
                      DataCell(Text(
                        '${fare.special}',
                        style: FareTableStyle.cellTextStyle.copyWith(
                          color: fare.specialColor, 
                        ),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
    required Color primaryColor,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      enabled: enabled,
      style: const TextStyle(color: Colors.black),
    );
  }
}
