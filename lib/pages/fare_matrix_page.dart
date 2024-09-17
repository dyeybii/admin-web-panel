import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web_panel/Style/fare_table_style.dart';
import 'package:admin_web_panel/widgets/fare_table.dart';

class FareMatrixPage extends StatefulWidget {
  static const String id = "webPageDriverManagement";

  const FareMatrixPage({Key? key}) : super(key: key);

  @override
  _FareMatrixPageState createState() => _FareMatrixPageState();
}

class _FareMatrixPageState extends State<FareMatrixPage> {
  TextEditingController basefareController = TextEditingController();
  TextEditingController addedkmController = TextEditingController();
  TextEditingController totalfareFareController = TextEditingController();

  bool isEditing = false; // Track if the form is in edit mode
  late DocumentSnapshot currentParameters; // Firestore document snapshot

  @override
  void initState() {
    super.initState();
    _loadFareParameters(); // Load fare parameters on init
  }

  Future<void> _loadFareParameters() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('fareParameters')
          .doc('currentParameters')
          .get();

      setState(() {
        currentParameters = doc;
        basefareController.text = doc['baseFareAmount'].toString();
        addedkmController.text = doc['distancePerKmAmount'].toString();
        totalfareFareController.text = doc['durationPerMinuteAmount'].toString();
      });
    } catch (e) {
      // Handle errors (e.g., document not found)
      print('Error loading fare parameters: $e');
    }
  }

  Future<void> _saveFareParameters() async {
    try {
      await FirebaseFirestore.instance
          .collection('fareParameters')
          .doc('currentParameters')
          .update({
        'baseFareAmount': double.parse(basefareController.text),
        'distancePerKmAmount': double.parse(addedkmController.text),
        'durationPerMinuteAmount': double.parse(totalfareFareController.text),
      });

      setState(() {
        isEditing = false; // Exit edit mode after saving
      });
    } catch (e) {
      print('Error saving fare parameters: $e');
    }
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing; // Toggle between edit and view modes
    });
  }

  void _cancelEdit() {
    setState(() {
      isEditing = false; // Exit edit mode without saving
      // Reset fields to original values
      basefareController.text = currentParameters['baseFareAmount'].toString();
      addedkmController.text =
          currentParameters['distancePerKmAmount'].toString();
      totalfareFareController.text =
          currentParameters['durationPerMinuteAmount'].toString();
    });
  }

  void _showFareTableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fare Table'),
          content: SingleChildScrollView(
            child: DataTable(
              columns: <DataColumn>[
                DataColumn(
                  label: Text('From', style: FareTableStyle.headerTextStyle),
                ),
                DataColumn(
                  label: Text('To', style: FareTableStyle.headerTextStyle),
                ),
                DataColumn(
                  label: Text('Distance', style: FareTableStyle.headerTextStyle),
                ),
                DataColumn(
                  label: Text('Special', style: FareTableStyle.headerTextStyle),
                ),
              ],
              rows: fareTable.map((fare) {
                return DataRow(cells: [
                  DataCell(
                    Text(
                      fare.from.isEmpty ? ' ' : fare.from,
                      style: FareTableStyle.cellTextStyle,
                    ),
                  ),
                  DataCell(
                    Text(
                      fare.to,
                      style: FareTableStyle.cellTextStyle,
                    ),
                  ),
                  DataCell(
                    Text(
                      '${fare.distance} km',
                      style: FareTableStyle.cellTextStyle,
                    ),
                  ),
                  DataCell(
                    Text(
                      '${fare.special}',
                      style: FareTableStyle.cellTextStyle,
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Text color
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Fare Matrix"),
        actions: [
          ElevatedButton(
            onPressed: _showFareTableDialog,
            child: const Text(
              'Fare Table',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  height: 500,
                  width: 600,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    border: Border.all(
                      color: const Color.fromARGB(255, 185, 185, 185),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Fare Matrix in COTODA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black, // Text color
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: basefareController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(255, 176, 176, 176)),
                            ),
                            labelText: 'Base Fare amount',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          enabled: isEditing, // Disable input if not editing
                          style: const TextStyle(color: Colors.black), // Input text color
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: addedkmController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            labelText: 'Distance added per kilometer amount',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          enabled: isEditing, // Disable input if not editing
                          style: const TextStyle(color: Colors.black), // Input text color
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: totalfareFareController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            labelText: 'Duration per minute amount',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          enabled: isEditing, // Disable input if not editing
                          style: const TextStyle(color: Colors.black), // Input text color
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isEditing)
                              ElevatedButton(
                                onPressed: _toggleEditMode,
                                child: const Text('Change Fare'),
                              ),
                            if (isEditing) ...[
                              ElevatedButton(
                                onPressed: _saveFareParameters,
                                child: const Text('Save'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _cancelEdit,
                                child: const Text('Cancel'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
