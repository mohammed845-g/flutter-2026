import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_5/models/units_model.dart';
import '../services/unit_service.dart';

class ManagePropertiesPage extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;

  const ManagePropertiesPage({
    super.key,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  State<ManagePropertiesPage> createState() => _ManagePropertiesPageState();
}

class _ManagePropertiesPageState extends State<ManagePropertiesPage> {
  late final SupabaseClient supabase;
  final UnitApiService _apiService = UnitApiService();
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    isAdmin = widget.currentUserRole == 'admin';
  }

  Future<void> _deleteProperty(String unitId) async {
    final bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Unit'),
            content: const Text(
              'Are you sure you want to permanently delete this unit?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        bool success = await _apiService.deleteUnit(unitId);
        if (success && mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unit deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
        }
      }
    }
  }

  void _showAddUnitBottomSheet({Units? existingUnit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddUnitBottomSheet(
        adminUid: widget.currentUserId,
        existingUnit: existingUnit,
        onSaveSuccess: () {
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Units>>(
        future: _apiService.getAllUnits(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final units = snapshot.data ?? [];

          if (units.isEmpty) {
            return const Center(child: Text('No units found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: units.length,
            itemBuilder: (context, index) {
              final unit = units[index];
              final status = unit.status;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        '${unit.location.developer} - ${unit.type}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Title: ${unit.title}\n'
                        'Location: ${unit.location.city}, ${unit.location.area}\n'
                        'Price: ${unit.price} EGP | Rooms: ${unit.bedrooms}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isAdmin) ...[
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 22,
                              ),
                              onPressed: () =>
                                  _showAddUnitBottomSheet(existingUnit: unit),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 22,
                              ),
                              onPressed: () => _deleteProperty(unit.id),
                            ),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'Sold'
                                  ? Colors.green
                                  : Colors.blue,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddUnitBottomSheet(),
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class AddUnitBottomSheet extends StatefulWidget {
  final String adminUid;
  final Units? existingUnit;
  final VoidCallback onSaveSuccess;

  const AddUnitBottomSheet({
    super.key,
    required this.adminUid,
    this.existingUnit,
    required this.onSaveSuccess,
  });

  @override
  State<AddUnitBottomSheet> createState() => _AddUnitBottomSheetState();
}

class _AddUnitBottomSheetState extends State<AddUnitBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final UnitApiService _apiService = UnitApiService();

  late TextEditingController _titleCtrl,
      _descCtrl,
      _typeCtrl,
      _priceCtrl,
      _areaCtrl,
      _bedroomsCtrl,
      _bathroomsCtrl,
      _floorCtrl,
      _devCtrl,
      _cityCtrl,
      _areaLocCtrl;

  bool isLoading = false;
  bool get isEditing => widget.existingUnit != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingUnit?.title ?? '');
    _descCtrl = TextEditingController(
      text: widget.existingUnit?.description ?? '',
    );
    _typeCtrl = TextEditingController(text: widget.existingUnit?.type ?? '');
    _priceCtrl = TextEditingController(
      text: widget.existingUnit?.price.toString() ?? '',
    );
    _areaCtrl = TextEditingController(
      text: widget.existingUnit?.area.toString() ?? '',
    );
    _bedroomsCtrl = TextEditingController(
      text: widget.existingUnit?.bedrooms.toString() ?? '',
    );
    _bathroomsCtrl = TextEditingController(
      text: widget.existingUnit?.bathrooms.toString() ?? '',
    );
    _floorCtrl = TextEditingController(
      text: widget.existingUnit?.floor.toString() ?? '',
    );
    _devCtrl = TextEditingController(
      text: widget.existingUnit?.location.developer ?? '',
    );
    _cityCtrl = TextEditingController(
      text: widget.existingUnit?.location.city ?? '',
    );
    _areaLocCtrl = TextEditingController(
      text: widget.existingUnit?.location.area ?? '',
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _typeCtrl.dispose();
    _priceCtrl.dispose();
    _areaCtrl.dispose();
    _bedroomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    _floorCtrl.dispose();
    _devCtrl.dispose();
    _cityCtrl.dispose();
    _areaLocCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final int? parsedPrice = int.tryParse(_priceCtrl.text.trim());
    final int? parsedArea = int.tryParse(_areaCtrl.text.trim());
    final int? parsedBedrooms = int.tryParse(_bedroomsCtrl.text.trim());
    final int? parsedBathrooms = int.tryParse(_bathroomsCtrl.text.trim());
    final int? parsedFloor = int.tryParse(_floorCtrl.text.trim());

    if (parsedPrice == null ||
        parsedArea == null ||
        parsedBedrooms == null ||
        parsedBathrooms == null ||
        parsedFloor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid numeric numbers for Price, Area, Rooms, Bathrooms and Floor',
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      Units unitData = Units(
        id: isEditing ? widget.existingUnit!.id : '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        type: _typeCtrl.text.trim(),
        status: isEditing ? widget.existingUnit!.status : 'Available',
        price: parsedPrice,
        area: parsedArea,
        bedrooms: parsedBedrooms,
        bathrooms: parsedBathrooms,
        floor: parsedFloor,
        createdAt: isEditing ? widget.existingUnit!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: isEditing ? widget.existingUnit!.isDeleted : false,
        location: Location(
          city: _cityCtrl.text.trim(),
          area: _areaLocCtrl.text.trim(),
          developer: _devCtrl.text.trim(),
        ),
      );

      if (isEditing) {
        await _apiService.updateUnit(widget.existingUnit!.id, unitData);
      } else {
        await _apiService.addNewUnit(unitData);
      }

      if (mounted) {
        widget.onSaveSuccess();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Unit updated successfully'
                  : 'Unit added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'Edit Unit' : 'Add New Unit',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 15),
              _buildField(_titleCtrl, 'Title'),
              _buildField(_descCtrl, 'Description'),
              _buildField(_typeCtrl, 'Unit Type'),
              _buildField(
                _priceCtrl,
                'Price (EGP)',
                keyboardType: TextInputType.number,
              ),
              _buildField(
                _areaCtrl,
                'Area (Sqm)',
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      _bedroomsCtrl,
                      'Bedrooms',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      _bathroomsCtrl,
                      'Bathrooms',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      _floorCtrl,
                      'Floor',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),
              const Text(
                'Location Details',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _buildField(_devCtrl, 'Developer'),
              _buildField(_cityCtrl, 'City'),
              _buildField(_areaLocCtrl, 'Area / Neighborhood'),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(isEditing ? 'Save Changes' : 'Add Unit'),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }
}
