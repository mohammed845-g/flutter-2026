import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/session_manager.dart';
import 'package:dio/dio.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool isLoading = false;
  String adminName = '';
  String adminEmail = '';
  String adminPhone = '';
  String profileUrl = '';

  final supabase = Supabase.instance.client;
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://192.168.1.11:3000"));

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    setState(() {
      adminName = SessionManager.userName;
      adminEmail = SessionManager.userEmail;
      adminPhone = SessionManager.userPhone.isEmpty ? 'Not Set' : SessionManager.userPhone;
      profileUrl = SessionManager.profileUrl;
    });
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image == null) return;

    setState(() => isLoading = true);
    try {
      final bytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = 'admin_${SessionManager.userId}_profile.$fileExt';
      final filePath = 'profiles/$fileName';

      // رفع الصورة لـ Supabase Storage
      await supabase.storage.from('profile-image').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage.from('profile-image').getPublicUrl(filePath);

      // تحديث الصورة في سيرفر الـ Node.js
      await _dio.put('/api/admins/${SessionManager.userId}', data: {
        'profileUrl': publicUrl,
      });

      // حفظ التحديث في سشن التطبيق الحالية
      SessionManager.mergeProfile({'profileUrl': publicUrl});
      
      if (mounted) {
        setState(() => profileUrl = publicUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _editField(String field, String currentVal) async {
    final ctrl = TextEditingController(text: currentVal == 'Not Set' ? '' : currentVal);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update $field'),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: 'Enter new $field'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newVal = ctrl.text.trim();
              if (newVal.isEmpty) return;
              Navigator.pop(ctx);
              setState(() => isLoading = true);
              try {
                // تحديث البيانات على الباك إند
                await _dio.put('/api/admins/${SessionManager.userId}', data: {
                  field: newVal,
                });

                // دمج التغيير في الـ SessionManager
                SessionManager.mergeProfile({field: newVal});
                _loadProfileData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
              } finally {
                if (mounted) setState(() => isLoading = false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
                          child: profileUrl.isEmpty ? const Icon(Icons.person, size: 65, color: Colors.grey) : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: const CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 20,
                              child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoCard('name', adminName, Icons.person, () => _editField('name', adminName)),
                  _buildInfoCard('phone', adminPhone, Icons.phone, () => _editField('phone', adminPhone)),
                  _buildInfoCard('email', adminEmail, Icons.email, () {}, isEmail: true),
                  const SizedBox(height: 40),
                  Text(
                    'Real Estate CRM Admin Panel',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, VoidCallback onTap, {bool isEmail = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: isEmail ? null : IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onTap),
      ),
    );
  }
}