import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeClientsPage extends StatefulWidget {
  const EmployeeClientsPage({super.key});

  @override
  State<EmployeeClientsPage> createState() =>
      _EmployeeClientsPageState();
}

class _EmployeeClientsPageState extends State<EmployeeClientsPage> {
  final user = FirebaseAuth.instance.currentUser;
  String searchQuery = '';

  Stream<QuerySnapshot> _clientsStream(String status) {
    // FIX: Return empty stream safely if user is null.
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('leads')
        .where('assignedTo', isEqualTo: user!.uid)
        .where('status', isEqualTo: status)
        .snapshots();
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('leads')
          .doc(docId)
          .update({'status': newStatus});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Moved to $newStatus')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildClientsTab(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _clientsStream(status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.red));
        }

        // FIX: Handle null data gracefully.
        final allDocs = snapshot.data?.docs ?? [];
        final docs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final phone = (data['phone'] ?? '').toString();
          return name.contains(searchQuery.toLowerCase()) ||
              phone.contains(searchQuery);
        }).toList();

        if (docs.isEmpty) {
          return Center(child: Text('No $status leads found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String name = data['name'] ?? 'Unknown';
            final String? purchasedUnit = data['purchasedUnit'];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade400,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: ${data['phone'] ?? 'N/A'}'),
                    if (purchasedUnit != null &&
                        purchasedUnit.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Purchased: $purchasedUnit',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (val) =>
                      _updateStatus(docs[index].id, val),
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(
                        value: 'potential',
                        child: Text('Potential')),
                    PopupMenuItem(
                        value: 'active', child: Text('Active')),
                    PopupMenuItem(
                        value: 'client', child: Text('Client')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon:
                    const Icon(Icons.search, color: Colors.red),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const TabBar(
            labelColor: Colors.red,
            indicatorColor: Colors.red,
            tabs: [
              Tab(text: 'Potential'),
              Tab(text: 'Active'),
              Tab(text: 'Clients'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildClientsTab('potential'),
                _buildClientsTab('active'),
                _buildClientsTab('client'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}