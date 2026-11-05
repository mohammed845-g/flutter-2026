import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import 'manage_properties.dart';
import 'login_admin.dart';
import 'admin_profile_page.dart';

// ودع هدول الصفحات الـ Placeholder أو استبدلهم بملفاتك الفعلية
class ManageEmployeesPage extends StatelessWidget { const ManageEmployeesPage({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('Manage Employees')); }
class ManageClients extends StatelessWidget { const ManageClients({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('Manage Clients')); }

class AdminHomeTabsPage extends StatefulWidget {
  const AdminHomeTabsPage({super.key});

  @override
  State<AdminHomeTabsPage> createState() => _AdminHomeTabsPageState();
}

class _AdminHomeTabsPageState extends State<AdminHomeTabsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.red),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.red),
            ),
            accountName: Text(SessionManager.userName.isEmpty ? 'Admin' : SessionManager.userName),
            accountEmail: Text(SessionManager.userEmail),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProfilePage()),
              );
              setState(() {}); // إعادة البناء لتحديث الصورة والاسم عند العودة
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              SessionManager.clear(); // تم حل الإيرور هنا بإنشاء دالة الـ clear
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginAdminPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Employees'),
            Tab(text: 'Clients'),
            Tab(text: 'Properties'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ManageEmployeesPage(),
          const ManageClients(),
          // قمنا بتمرير الـ ID والـ Role لصفحة الخصائص عشان تتطابق مع التعديل اللي عملناه فوق
          ManagePropertiesPage(
            currentUserId: SessionManager.userId, 
            currentUserRole: SessionManager.userRole,
          ),
        ],
      ),
    );
  }
}