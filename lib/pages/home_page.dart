import 'package:flutter/material.dart';
import '../services/session_manager.dart'; 
import 'units.dart';
import 'login_employee.dart';
import 'employee_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double myEarnings = 0.0;
  int unitsSold = 0;
  final int targetUnits = 10; 

  void _updateProgress(double price) {
    setState(() {
      if (price > 0) {
        myEarnings += (price * 0.02); 
        unitsSold += 1;
      } else {
        myEarnings += (price * 0.02); 
        if (unitsSold > 0) unitsSold -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // تم تعديل الشرط هنا ليقرأ الـ getter اللي اسمه userId مباشرة
    if (SessionManager.userId.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Session expired. Please login again.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // هنا يمكنك التوجيه لصفحة الـ LoginEmployeePage مباشرة أو صفحة الاختيار
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginEmployeePage()),
                    (route) => false,
                  );
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    double progress = unitsSold / targetUnits;
    if (progress > 1.0) progress = 1.0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Text('Welcome, ${SessionManager.userName}'),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: "Dashboard"),
              Tab(icon: Icon(Icons.home_work), text: "Units"),
              Tab(icon: Icon(Icons.person), text: "Profile"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Dashboard Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _statCard('My Commissions Earnings', '${myEarnings.toStringAsFixed(2)} EGP', Icons.payments, Colors.green),
                  const SizedBox(height: 16),
                  _progressCard(progress, unitsSold, targetUnits),
                ],
              ),
            ),
            // Units Tab
            UnitsPage(
              currentUserId: SessionManager.userId,
              onUnitSold: _updateProgress,
            ),
            // Profile Tab
            const EmployeeProfilePage(),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 28,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _progressCard(double progress, int sold, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        children: [
          const Text(
            'Achievement Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 130,
                width: 130,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$sold sold out of $total units',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}