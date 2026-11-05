import 'package:flutter/material.dart';
import 'package:flutter_application_5/models/units_model.dart';

class DetailsPage extends StatelessWidget {
  final Units unitData;

  const DetailsPage({super.key, required this.unitData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(unitData.title.isEmpty ? 'Unit Details' : unitData.title),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.image, size: 60, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unit Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Divider(thickness: 1.5),
                  const SizedBox(height: 10),
                  _infoTile(Icons.title, 'Title', unitData.title),
                  _infoTile(
                    Icons.description,
                    'Description',
                    unitData.description,
                  ),
                  _infoTile(
                    Icons.business,
                    'Developer',
                    unitData.location.developer,
                  ),
                  _infoTile(
                    Icons.location_city,
                    'City',
                    unitData.location.city,
                  ),
                  _infoTile(Icons.map, 'Area Location', unitData.location.area),
                  _infoTile(Icons.home_work, 'Unit Type', unitData.type),
                  _infoTile(Icons.payments, 'Price', '${unitData.price} EGP'),
                  _infoTile(
                    Icons.king_bed,
                    'Bedrooms',
                    unitData.bedrooms.toString(),
                  ),
                  _infoTile(
                    Icons.bathtub,
                    'Bathrooms',
                    unitData.bathrooms.toString(),
                  ),
                  _infoTile(Icons.layers, 'Floor', unitData.floor.toString()),
                  _infoTile(
                    Icons.assignment_turned_in,
                    'Status',
                    unitData.status,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.redAccent, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  (value == null || value.trim().isEmpty) ? 'N/A' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
