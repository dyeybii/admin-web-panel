import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';

class BlacklistDialog extends StatefulWidget {
  @override
  _BlacklistDialogState createState() => _BlacklistDialogState();
}

class _BlacklistDialogState extends State<BlacklistDialog> {
  final DatabaseReference _driversRef = FirebaseDatabase.instance.ref().child('driversAccount');
  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _filteredDrivers = [];
  bool _isProcessing = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDrivers();
    _searchController.addListener(_filterDrivers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchDrivers() async {
    try {
      final snapshot = await _driversRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _drivers = data.entries
              .where((entry) =>
                  (entry.value as Map<dynamic, dynamic>).containsKey('firstName'))
              .map((entry) {
            final value = Map<String, dynamic>.from(entry.value);
            return {
              'driverId': entry.key,
              'uid': value['uid'], // Ensure 'uid' field exists in Firebase data
              'fullName': '${value['firstName']} ${value['lastName'] ?? ''}',
              'driverPhoto': value['driverPhoto'] ?? '', // Add driver photo field
              'status': value['status'] ?? 'active', // Default to active if not defined
            };
          }).toList();
          _filteredDrivers = List.from(_drivers);
        });
      }
    } catch (e) {
      print('Error fetching drivers: $e');
    }
  }

  void _filterDrivers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDrivers = _drivers
          .where((driver) => driver['fullName'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> blockOrUnblockDriver(String driverId, bool disable) async {
    setState(() {
      _isProcessing = true;
    });
    try {
      // Assuming 'uid' is stored in the driver data
      final driver = _drivers.firstWhere((d) => d['driverId'] == driverId);
      final uid = driver['uid']; // Ensure the `uid` field exists.

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('blockUser');
      await callable.call({'uid': uid, 'disable': disable});

      await _driversRef.child(driverId).update({'status': disable ? 'blocked' : 'active'});

      fetchDrivers(); // Refresh the list after status update
    } catch (e) {
      print('Error blocking/unblocking driver: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${disable ? 'block' : 'unblock'} the driver')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7, // Adjusted width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _filteredDrivers.isEmpty
                    ? const Center(child: Text('No drivers found'))
                    : ListView.builder(
                        itemCount: _filteredDrivers.length,
                        itemBuilder: (context, index) {
                          final driver = _filteredDrivers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: driver['driverPhoto'].isNotEmpty
                                  ? NetworkImage(driver['driverPhoto'])
                                  : null,
                              child: driver['driverPhoto'].isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(driver['fullName']),
                            subtitle: Text(
                                'Driver ID: ${driver['driverId']}\nStatus: ${driver['status']}'),
                            trailing: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () {
                                      final disable = driver['status'] != 'blocked';
                                      blockOrUnblockDriver(driver['driverId'], disable);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: driver['status'] == 'blocked'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              child: Text(driver['status'] == 'blocked' ? 'Unblock' : 'Block'),
                            ),
                          );
                        },
                      ),
              ),
            ),
            // Footer Actions
            Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
