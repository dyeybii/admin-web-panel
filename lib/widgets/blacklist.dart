import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_web_panel/Data_service.dart';
import 'package:admin_web_panel/Style/appstyle.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';

class BlacklistDialog extends StatefulWidget {
  @override
  _BlacklistDialogState createState() => _BlacklistDialogState();
}

class _BlacklistDialogState extends State<BlacklistDialog> {
  final DataService _dataService = DataService();
  bool _isLoading = false;

  // Method to toggle the driver status between 'blocked' and 'unblocked'
  void _toggleDriverStatus(DriversAccount driver) async {
    setState(() {
      _isLoading = true;
    });

    final newStatus = driver.status == 'blocked' ? 'unblocked' : 'blocked';

    try {
      // Update the driver's status in the Firebase Realtime Database
      await _dataService.updateDriverStatus(driver.driverId, newStatus);

      // After the update, refresh the UI
      setState(() {
        driver.status = newStatus;
        _isLoading = false;
      });
    } catch (e) {
      print("Error updating driver status: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: const BoxDecoration(
          color: Color(0xFF2E3192),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Blacklist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      content: SizedBox(
        height: 400,
        width: 400,
        child: StreamBuilder<DatabaseEvent>(
          stream: _dataService.getDriversStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text('No drivers found.'));
            }

            final data = snapshot.data!.snapshot.value;
            if (data is Map<dynamic, dynamic>) {
              final driversList = data.entries
                  .map((entry) {
                    final driverData = Map<String, dynamic>.from(entry.value);
                    if (driverData.containsKey('firstName') &&
                        driverData.containsKey('lastName') &&
                        driverData.containsKey('status')) {
                      return DriversAccount.fromJson(driverData);  // Fixed constructor call
                    }
                    return null;
                  })
                  .whereType<DriversAccount>()
                  .toList();

              if (driversList.isEmpty) {
                return const Center(child: Text('No valid driver data.'));
              }

              return ListView.builder(
                itemCount: driversList.length,
                itemBuilder: (context, index) {
                  final driver = driversList[index];
                  return ListTile(
                    title: Text('${driver.firstName} ${driver.lastName}'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: driver.status == 'blocked'
                            ? Colors.red
                            : Colors.green,
                      ),
                      onPressed: _isLoading ? null : () {
                        _toggleDriverStatus(driver);
                      },
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text(driver.status == 'blocked' ? 'Unblock' : 'Block'),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('Unexpected data format.'));
            }
          },
        ),
      ),
      actions: [
        TextButton(
          style: CustomButtonStyles.elevatedButtonStyle,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
