import 'package:admin_web_panel/responsive/driver_form_mobile.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_web_panel/Data_service.dart';
import 'package:admin_web_panel/widgets/driver_table.dart';


class DriversPageMobile extends StatefulWidget {
  const DriversPageMobile({Key? key}) : super(key: key);

  @override
  State<DriversPageMobile> createState() => _DriversPageMobileState();
}

class _DriversPageMobileState extends State<DriversPageMobile> {
  final DataService _dataService = DataService();
  List<DriversAccount> _driversAccountList = [];
  List<DriversAccount> _filteredDriversList = [];
  List<DriversAccount> _selectedDrivers = [];
  final TextEditingController searchController = TextEditingController();
  String selectedTagFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchDriversData();
    searchController.addListener(_filterDrivers);
  }

  Future<void> _fetchDriversData() async {
    try {
      List<DriversAccount> driversList =
          await _dataService.getDriversFromRealtimeDatabase();
      if (mounted) {
        setState(() {
          _driversAccountList = driversList;
          _filteredDriversList = driversList;
        });
      }
    } catch (e) {
      print('Error fetching drivers: $e');
    }
  }

  void _filterDrivers() {
    setState(() {
      String query = searchController.text.toLowerCase();
      _filteredDriversList = _driversAccountList.where((driver) {
        final matchesSearch = driver.firstName.toLowerCase().contains(query) ||
            driver.lastName.toLowerCase().contains(query);
        final matchesTag =
            selectedTagFilter == 'All' || driver.tag == selectedTagFilter;
        return matchesSearch && matchesTag;
      }).toList();
    });
  }

  void _filterByTag(String? tag) {
    setState(() {
      selectedTagFilter = tag ?? 'All';
      _filterDrivers();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Drivers'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchDriversData,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search drivers...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: Icon(Icons.search,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedTagFilter,
                    items: ['All', 'Operator', 'Member'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: _filterByTag,
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _dataService.getDriversStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Center(child: Text('No drivers found.'));
                  }

                  final data = snapshot.data!.snapshot.value;

                  if (data is Map<dynamic, dynamic>) {
                    final driversList = data.entries
                        .map((entry) => DriversAccount.fromJson(
                            Map<String, dynamic>.from(entry.value)))
                        .whereType<
                            DriversAccount>() // This ensures the list contains only non-null DriversAccount objects
                        .toList();

                    return DriverTable(
                      driversAccountList: _filteredDriversList.isNotEmpty
                          ? _filteredDriversList
                          : driversList,
                      selectedDrivers: _selectedDrivers,
                      onSelectedDriversChanged:
                          (List<DriversAccount> selected) {
                        setState(() {
                          _selectedDrivers = selected;
                        });
                      },
                    );
                  } else {
                    return const Center(child: Text('Unexpected data format.'));
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () => _showAddDriverForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Driver'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDriverForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add New Driver'),
          content: DriversFormMobile(
            formKey: GlobalKey<FormState>(),
            firstNameController: TextEditingController(),
            lastNameController: TextEditingController(),
            idNumberController: TextEditingController(),
            bodyNumberController: TextEditingController(),
            emailController: TextEditingController(),
            birthdateController: TextEditingController(),
            addressController: TextEditingController(),
            phoneNumberController: TextEditingController(),
            tagController: TextEditingController(),
            uidController: TextEditingController(),
            driverPhotoController: TextEditingController(),
            codingSchemeController: TextEditingController(),
            statusController: TextEditingController(),
            onAddPressed: () {
              // Add driver implementation
            },
            onTagSelected: (String? tag) {
              // Handle tag selection
            },
          ),
        );
      },
    );
  }
}
