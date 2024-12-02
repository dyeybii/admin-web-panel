import 'package:admin_web_panel/responsive/driver_form_mobile.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin_web_panel/data_service.dart';
import 'package:admin_web_panel/widgets/driver_table.dart';

class DriversPageMobile extends StatefulWidget {
  const DriversPageMobile({Key? key}) : super(key: key);

  @override
  State<DriversPageMobile> createState() => _DriversPageMobileState();
}

class _DriversPageMobileState extends State<DriversPageMobile> {
  bool isLoading = false;
  bool noResultsFound = false;
  final DataService _dataService = DataService();
  List<DriversAccount> _driversAccountList = [];
  List<DriversAccount> _filteredDriversList = [];
  List<DriversAccount> _selectedDrivers = [];
  String selectedTagFilter = 'All';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterDrivers); // Filter when search text changes
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final driversList = await _dataService.fetchDrivers();
      setState(() {
        _driversAccountList = driversList;
        _filteredDriversList = driversList; // Initialize filtered list with all drivers
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching drivers: $e");
    }
  }

  // Updated filter function
  void _filterDrivers() {
    setState(() {
      String query = searchController.text.toLowerCase();
      _filteredDriversList = _driversAccountList.where((driver) {
        // Filter by search query
        final matchesSearch = driver.firstName.toLowerCase().contains(query) ||
            driver.lastName.toLowerCase().contains(query);
        // Filter by tag selection
        final matchesTag =
            selectedTagFilter == 'All' || driver.tag == selectedTagFilter;
        return matchesSearch && matchesTag;
      }).toList();
    });
  }

  // Handle tag filtering
  void _filterByTag(String? tag) {
    setState(() {
      selectedTagFilter = tag ?? 'All';
      _filterDrivers();  // Re-filter drivers whenever the tag changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Member Management'),
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
                        suffixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedTagFilter,
                    items: ['All', 'Operator', 'Member'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: _filterByTag, // Filter by tag when changed
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredDriversList.isEmpty
                      ? const Center(child: Text('No drivers found.'))
                      : DriverTable(
                          driversAccountList: _filteredDriversList,
                          selectedDrivers: _selectedDrivers,
                          onSelectedDriversChanged: (List<DriversAccount> selected) {
                            setState(() {
                              _selectedDrivers = selected;
                            });
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}


