import 'package:admin_web_panel/data_service.dart';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/widgets/fare_table.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FareMatrixPage extends StatefulWidget {
  static const String id = "webPageDriverManagement";

  const FareMatrixPage({Key? key}) : super(key: key);

  @override
  _FareMatrixDesktopState createState() => _FareMatrixDesktopState();
}

class _FareMatrixDesktopState extends State<FareMatrixPage> {
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
                      style: CustomButtonStyles.elevatedButtonStyle,
                      child: const Text('Save Fare'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _cancelEdit,
                      style: CustomButtonStyles.elevatedButtonStyle,
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
    required Color primaryColor,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildFareTableContainer(Color primaryColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Column(
          children: [
            if (isMobile) ...[
              _buildSingleFareTable(
                title: 'Coloong 1 Fare Table',
                fareList: coloong1,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 20),
              _buildSingleFareTable(
                title: 'Coloong 2 Fare Table',
                fareList: coloong2,
                primaryColor: primaryColor,
              ),
            ]
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSingleFareTable(
                      title: 'Coloong 1 Fare Table',
                      fareList: coloong1,
                      primaryColor: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildSingleFareTable(
                      title: 'Coloong 2 Fare Table',
                      fareList: coloong2,
                      primaryColor: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

Widget _buildSingleFareTable({
  required String title,
  required List<Fare> fareList,
  required Color primaryColor,
}) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 15),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            border: TableBorder.all(
              color: primaryColor,
              width: 1,
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                children: const [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'From',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'To',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Distance',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Special',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              for (var fare in fareList)
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(fare.from.isEmpty ? ' ' : fare.from),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(fare.to),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${fare.distance} km'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${fare.special}'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

}
