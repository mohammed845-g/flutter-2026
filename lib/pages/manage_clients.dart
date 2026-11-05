import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageClients extends StatefulWidget {
  const ManageClients({super.key});

  @override
  State<ManageClients> createState() => _ManageClientsState();
}

class _ManageClientsState extends State<ManageClients>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // FIX: Dispose TabController to free animation resources.
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openLeadSheet({DocumentSnapshot? doc}) {
    final nameController = TextEditingController(
      text: doc != null ? doc['name'] : '',
    );
    final phoneController = TextEditingController(
      text: doc != null ? doc['phone'] : '',
    );
    String? selectedEmpId = doc != null ? doc['assignedTo'] : null;
    String? selectedEmpName =
        doc != null ? doc['assignedToName'] : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                doc == null ? 'Add New Lead' : 'Edit Lead',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Client Name'),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Phone Number'),
              ),
              const SizedBox(height: 15),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'employee')
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const LinearProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: selectedEmpId,
                    hint: const Text('Assign to Employee'),
                    items: snap.data!.docs
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(e['name']),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedEmpId = val;
                        selectedEmpName = snap.data!.docs
                            .firstWhere((e) => e.id == val)['name'];
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  // FIX: Validate name is not empty before saving.
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Client name is required')),
                    );
                    return;
                  }
                  final data = {
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'assignedTo': selectedEmpId,
                    'assignedToName': selectedEmpName,
                    'status':
                        doc == null ? 'potential' : doc['status'],
                    'updatedAt': FieldValue.serverTimestamp(),
                  };
                  if (doc == null) {
                    await FirebaseFirestore.instance
                        .collection('leads')
                        .add(data);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('leads')
                        .doc(doc.id)
                        .update(data);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text(
                  'Save Lead',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      // FIX: Dispose local controllers when sheet is closed.
      nameController.dispose();
      phoneController.dispose();
    });
  }

  Widget _buildLeadsList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('leads')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs
            .where(
              (d) => (d['name'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()),
            )
            .toList();

        if (docs.isEmpty) {
          return Center(
              child: Text('No $status leads found'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String? purchasedUnit = data['purchasedUnit'];

            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(
                  data['name'] ?? 'Unknown',
                  style:
                      const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone: ${data['phone'] ?? 'N/A'}\n'
                      'Assigned to: ${data['assignedToName'] ?? 'Unassigned'}',
                    ),
                    if (purchasedUnit != null &&
                        purchasedUnit.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Purchased: $purchasedUnit',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      _openLeadSheet(doc: docs[index]),
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _openLeadSheet(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (v) =>
                  setState(() => _searchText = v),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            indicatorColor: Colors.red,
            tabs: const [
              Tab(text: 'Potential'),
              Tab(text: 'Active'),
              Tab(text: 'Clients'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeadsList('potential'),
                _buildLeadsList('active'),
                _buildLeadsList('client'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}