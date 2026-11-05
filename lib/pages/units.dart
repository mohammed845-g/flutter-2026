import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'details_page.dart';
import 'package:flutter_application_5/models/units_model.dart';
import '../services/unit_service.dart';

class UnitsPage extends StatefulWidget {
  final String currentUserId;
  final Function(double) onUnitSold;

  const UnitsPage({
    super.key,
    required this.currentUserId,
    required this.onUnitSold,
  });

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
  final UnitApiService _apiService = UnitApiService();

  Future<void> _sellUnitToClient(
    Units unit,
    double price,
    String clientId,
  ) async {
    try {
      unit.status = 'Sold';
      await _apiService.updateUnit(unit.id, unit);

      await _apiService.dio.put(
        '/api/leads/$clientId',
        data: {
          'status': 'client',
          'purchasedUnit': '${unit.location.developer} - ${unit.type}',
        },
      );

      widget.onUnitSold(price);
      setState(() {});
    } catch (e) {
      debugPrint('Sell Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to sell unit: $e')));
      }
    }
  }

  Future<void> _undoSale(Units unit, double price) async {
    try {
      unit.status = 'Available';
      await _apiService.updateUnit(unit.id, unit);

      await _apiService.dio.put(
        '/api/leads/undo-sale',
        data: {'purchasedUnit': '${unit.location.developer} - ${unit.type}'},
      );

      widget.onUnitSold(-price);
      setState(() {});
    } catch (e) {
      debugPrint('Undo Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to undo sale: $e')));
      }
    }
  }

  void _showClientsSheet(Units unit, double price) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<Response>(
          future: _apiService.dio.get(
            '/api/leads/employee/${widget.currentUserId}?status=active',
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final List clients = snapshot.data?.data ?? [];
            if (clients.isEmpty) {
              return const Center(child: Text('No Active Clients found'));
            }

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select Client to Sell',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      final String clientId = client['_id']?.toString() ?? '';
                      final String clientName = client['name'] ?? 'Unknown';
                      return ListTile(
                        leading: const Icon(Icons.person, color: Colors.orange),
                        title: Text(clientName),
                        subtitle: Text(client['phone'] ?? 'N/A'),
                        onTap: () {
                          Navigator.pop(context);
                          _sellUnitToClient(unit, price, clientId);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Units>>(
      future: _apiService.getAllUnits(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final myUnits = snapshot.data ?? [];

        if (myUnits.isEmpty) {
          return const Center(child: Text('No Units Found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: myUnits.length,
          itemBuilder: (context, index) {
            return _unitCard(context, myUnits[index]);
          },
        );
      },
    );
  }

  Widget _unitCard(BuildContext ctx, Units unit) {
    final bool isSold = unit.status == 'Sold';
    final String unitTitle = '${unit.location.developer} - ${unit.type}';
    final double price = unit.price.toDouble();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            if (isSold)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'SOLD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              unitTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '${unit.price} EGP',
              style: const TextStyle(
                fontSize: 17,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => DetailsPage(unitData: unit),
                      ),
                    ),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isSold) {
                        showDialog(
                          context: ctx,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text(
                              'Are you sure you want to return this unit?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'No',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _undoSale(unit, price);
                                },
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        _showClientsSheet(unit, price);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSold ? Colors.grey : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Icon(isSold ? Icons.undo : Icons.check),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
