import 'package:flutter/material.dart';
import 'package:admin_web_panel/widgets/driver_table.dart';
import 'package:admin_web_panel/data_service.dart';
import 'package:admin_web_panel/widgets/drivers_account.dart';

class DriversPageMobile extends StatefulWidget {
  const DriversPageMobile({Key? key}) : super(key: key);

  @override
  State<DriversPageMobile> createState() => _DriversPageMobileState();
}

class _DriversPageMobileState extends State<DriversPageMobile> {
  bool isLoading = false;
  final DataService _dataService = DataService();
  List<DriversAccount> _driversAccountList = [];
  List<DriversAccount> _filteredDriversList = [];
  List<DriversAccount> _selectedDrivers = [];
  String selectedTagFilter = 'All';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterDrivers); // Apply filter when search text changes
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
        _filteredDriversList = driversList; // Initialize filtered list
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching drivers: $e");
    }
  }

  void _filterDrivers() {
    setState(() {
      String query = searchController.text.trim().toLowerCase();
      _filteredDriversList = _driversAccountList.where((driver) {
        // Match search query
        final matchesSearch = driver.firstName.toLowerCase().contains(query) ||
            driver.lastName.toLowerCase().contains(query);

        // Match tag selection (handle null or missing tags gracefully)
        final matchesTag = selectedTagFilter == 'All' ||
            (driver.tag?.toLowerCase() ?? '') == selectedTagFilter.toLowerCase();

        return matchesSearch && matchesTag;
      }).toList();
    });
  }

  void _filterByTag(String? tag) {
    setState(() {
      selectedTagFilter = tag ?? 'All';
      _filterDrivers(); // Reapply filter with updated tag
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Driver Management'),
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
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Color(0xFF2E3192)),
                        ),
                      );
                    }).toList(),
                    onChanged: _filterByTag,
                    underline: Container(),
                    iconEnabledColor: const Color(0xFF2E3192),
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

  @override
  void dispose() {
    searchController.removeListener(_filterDrivers);
    searchController.dispose();
    super.dispose();
  }
}
