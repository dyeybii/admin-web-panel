import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuditlogPage extends StatefulWidget {
  const AuditlogPage({Key? key}) : super(key: key);

  @override
  _AuditlogPageState createState() => _AuditlogPageState();
}

class _AuditlogPageState extends State<AuditlogPage> {
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<Map<String, Map<String, String>>> _fetchAdminDetails() async {
    try {
      final admins = await FirebaseFirestore.instance.collection('admin').get();
      return {
        for (var doc in admins.docs)
          doc.id: {
            'fullName': doc['fullName'] ?? 'Unknown',
            'email': doc['email'] ?? 'Unknown',
          },
      };
    } catch (e) {
      // Handle error gracefully
      debugPrint('Error fetching admin details: $e');
      return {}; // Return empty map on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double containerWidth =
                constraints.maxWidth < 800 ? constraints.maxWidth : 800;
            return Container(
              width: containerWidth,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: const Color(0xFF2E3192), width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<Map<String, Map<String, String>>>(
                future: _fetchAdminDetails(),
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (adminSnapshot.hasError || !adminSnapshot.hasData) {
                    return const Center(child: Text('Error loading admin data.'));
                  }

                  final adminData = adminSnapshot.data!;
                  return Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _buildAuditLogTable(adminData),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 250,
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: 'Search by Name',
            labelStyle: const TextStyle(color: Color(0xFF2E3192)),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF2E3192)),
              borderRadius: BorderRadius.circular(40),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF2E3192), width: 2.0),
              borderRadius: BorderRadius.circular(40),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF2E3192), width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: const Icon(
              Icons.search,
              color: Color(0xFF2E3192),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildAuditLogTable(Map<String, Map<String, String>> adminData) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, logSnapshot) {
        if (logSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (logSnapshot.hasError || !logSnapshot.hasData || logSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No audit logs available.'));
        }

        final filteredDocs = logSnapshot.data!.docs.where((doc) {
          final adminId = doc['adminId'];
          final fullName = adminData[adminId]?['fullName'] ?? '';
          return fullName.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('User Email')),
              DataColumn(label: Text('Action')),
              DataColumn(label: Text('Timestamp')),
            ],
            rows: filteredDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final adminId = data['adminId'];
              final fullName = adminData[adminId]?['fullName'] ?? 'Unknown';
              final email = adminData[adminId]?['email'] ?? 'Unknown';
              final action = data['action'] ?? 'No Action';
              final timestamp = (data['timestamp'] as Timestamp?)
                      ?.toDate()
                      .toString() ??
                  'No Timestamp';

              return DataRow(cells: [
                DataCell(Text(fullName)),
                DataCell(Text(email)),
                DataCell(Text(action)),
                DataCell(Text(timestamp)),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}
