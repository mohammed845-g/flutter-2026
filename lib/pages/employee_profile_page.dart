import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/session_manager.dart';

// محاكاة لخدمة الـ ProfileService عشان متعملش إيرور لو مش موجودة
class ProfileService {
  static Future<Map<String, dynamic>> getProfile(String userId) async {
    // هنا المفروض بتكلم السيرفر بتاعك بـ Dio، للتبسيط بتقرأ من السشن أو السيرفر
    return {
      'name': SessionManager.userName,
      'email': SessionManager.userEmail,
      'phone': SessionManager.userPhone,
      'profileUrl': SessionManager.profileUrl,
    };
  }

  static Future<void> updateField(
    String userId,
    String field,
    String value,
  ) async {
    // دالة تحديث الحقل على السيرفر عندك عبر الـ API
  }
}

class EmployeeProfilePage extends StatefulWidget {
  const EmployeeProfilePage({super.key});

  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  bool isLoading = true;
  String empName = '';
  String empEmail = '';
  String empPhone = '';
  String profileUrl = '';

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) setState(() => isLoading = true);
    try {
      final data = await ProfileService.getProfile(SessionManager.userId);
      if (!mounted) return;
      setState(() {
        empName = data['name'] ?? SessionManager.userName;
        empEmail = data['email'] ?? SessionManager.userEmail;
        empPhone = data['phone'] ?? SessionManager.userPhone;
        profileUrl = data['profileUrl'] ?? SessionManager.profileUrl;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image == null) return;

    setState(() => isLoading = true);
    try {
      final bytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '${SessionManager.userId}_profile.$fileExt';
      final filePath = 'profiles/$fileName';

      await supabase.storage
          .from('profile-image')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage
          .from('profile-image')
          .getPublicUrl(filePath);

      await ProfileService.updateField(
        SessionManager.userId,
        'profileUrl',
        publicUrl,
      );

      SessionManager.mergeProfile({'profileUrl': publicUrl});
      setState(() => profileUrl = publicUrl);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _editField(String field, String label, String currentVal) {
    final ctrl = TextEditingController(text: currentVal);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: 'Enter new $label'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newVal = ctrl.text.trim();
              if (newVal.isEmpty) return;
              Navigator.pop(ctx);
              setState(() => isLoading = true);
              try {
                await ProfileService.updateField(
                  SessionManager.userId,
                  field,
                  newVal,
                );
                SessionManager.mergeProfile({field: newVal});
                _loadProfile();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                setState(() => isLoading = false);
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
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: profileUrl.isNotEmpty
                        ? NetworkImage(profileUrl)
                        : null,
                    child: profileUrl.isEmpty
                        ? const Icon(Icons.person, size: 65, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: _pickAndUploadImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _infoTile(
              'Name',
              empName,
              Icons.person,
              () => _editField('name', 'Name', empName),
            ),
            _infoTile(
              'Phone',
              empPhone,
              Icons.phone,
              () => _editField('phone', 'Phone', empPhone),
            ),
            _infoTile('Email', empEmail, Icons.email, null),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    String label,
    String value,
    IconData icon,
    VoidCallback? onEdit,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        subtitle: Text(
          value.isEmpty ? 'Not Set' : value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: onEdit != null
            ? IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
              )
            : null,
      ),
    );
  }
}
