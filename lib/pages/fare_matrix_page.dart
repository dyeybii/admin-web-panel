import 'package:admin_web_panel/widgets/fare_table.dart';
import 'package:admin_web_panel/widgets/fare_table_style.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Fare Matrix"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Example color
                      border: Border.all(
                        color: Colors.grey[400]!, // Example border color
                        width: 2, // Example border width
                      ),
                      borderRadius:
                          BorderRadius.circular(10), // Example border radius
                    ),
                    child: DataTable(
                      columns: <DataColumn>[
                        DataColumn(
                          label: Text('From',
                              style: FareTableStyle.headerTextStyle),
                        ),
                        DataColumn(
                          label:
                              Text('To', style: FareTableStyle.headerTextStyle),
                        ),
                        DataColumn(
                          label: Text('Distance',
                              style: FareTableStyle.headerTextStyle),
                        ),
                        DataColumn(
                          label: Text('Special',
                              style: FareTableStyle.headerTextStyle),
                        ),
                      ],
                      rows: fareTable.map((fare) {
                        return DataRow(cells: [
                          DataCell(
                            Text(
                              fare.from.isEmpty ? ' ' : fare.from,
                              style: FareTableStyle.cellTextStyle,
                            ),
                          ), // Avoid empty cells by adding a space
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
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 500,
                  width: 600,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Example color
                    border: Border.all(
                      color: Colors.grey[400]!, // Example border color
                      width: 2, // Example border width
                    ),
                    borderRadius:
                        BorderRadius.circular(10), // Example border radius
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
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: basefareController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Base Fare',
                            labelStyle: FareTableStyle.textFieldLabelStyle,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: addedkmController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Added Amount/km',
                            labelStyle: FareTableStyle.textFieldLabelStyle,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: totalfareFareController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Total Fare',
                            labelStyle: FareTableStyle.textFieldLabelStyle,
                          ),
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
