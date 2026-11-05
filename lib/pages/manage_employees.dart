import 'package:flutter/material.dart';
import 'package:flutter_application_5/models/employees_model.dart';
import 'package:flutter_application_5/services/employee_service.dart';

class ManageEmployeeScreen extends StatefulWidget {
  final Employees? employee; // لو جاي ببيانات يبقى تعديل (Edit)، لو null يبقى إضافة (Add)

  const ManageEmployeeScreen({Key? key, this.employee}) : super(key: key);

  @override
  State<ManageEmployeeScreen> createState() => _ManageEmployeeScreenState();
}

class _ManageEmployeeScreenState extends State<ManageEmployeeScreen> {
  final EmployeeApiService _apiService = EmployeeApiService();
  
  // الـ Controllers الخاصة بالـ TextFields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _deptController = TextEditingController();
  final _roleController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // لو بنعمل تعديل، بنملى الـ TextFields ببيانات الموظف الحالي تلقائياً
    if (widget.employee != null) {
      _nameController.text = widget.employee!.fullName;
      _phoneController.text = widget.employee!.phoneNumber;
      _emailController.text = widget.employee!.email;
      _deptController.text = widget.employee!.department;
      _roleController.text = widget.employee!.role;
    }
  }

  // فانكشن الحفظ (سواء إضافة أو تعديل)
  void _saveEmployee() async {
    setState(() => _isLoading = true);

    // 1. بنجهز الـ Object اللي هنبعته للـ Service
    Employees currentEmployee = Employees(
      id: widget.employee?.id ?? '', // لو جديد السيرفر بيدي الـ id، لو قديم بنثبته
      fullName: _nameController.text,
      phoneNumber: _phoneController.text,
      email: _emailController.text,
      passwordHash: widget.employee?.passwordHash ?? 'default_password', 
      department: _deptController.text,
      role: _roleController.text,
      hireDate: widget.employee?.hireDate ?? DateTime.now(),
      createdAt: widget.employee?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: widget.employee?.isDeleted ?? false,
    );

    Employees? result;

    if (widget.employee == null) {
      // إضافة موظف جديد
      result = await _apiService.addNewEmployee(currentEmployee);
    } else {
      // تعديل موظف حالي
      result = await _apiService.updateEmployee(widget.employee!.id, currentEmployee);
    }

    setState(() => _isLoading = false);

    if (result != null) {
      // نجحت العملية، نرجع للصفحة السابقة ونقفل
      Navigator.pop(context, true); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت العملية بنجاح!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ، حاول مرة أخرى')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.employee == null ? 'إضافة موظف' : 'تعديل بيانات موظف')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'الاسم بالكامل')),
                  TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف')),
                  TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
                  TextField(controller: _deptController, decoration: const InputDecoration(labelText: 'القسم')),
                  TextField(controller: _roleController, decoration: const InputDecoration(labelText: 'الدور الوظيفي')),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveEmployee,
                    child: Text(widget.employee == null ? 'إضافة' : 'حفظ التعديلات'),
                  )
                ],
              ),
            ),
          ),
    );
  }
}