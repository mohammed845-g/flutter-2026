import 'package:dio/dio.dart';
import 'package:flutter_application_5/models/employees_model.dart';

class EmployeeApiService {
  late Dio dio;
  EmployeeApiService() {
    dio = Dio(BaseOptions(baseUrl: "http://192.168.1.11:3000"));
  }
  Future<List<Employees>> getAllEmployees() async {
    Response<List> response = await dio.get('/api/employees');
    List<Employees> employees = [];
    if (response.data != null) {
      employees = List<Employees>.from(
        response.data!.map((e) => Employees.fromJson(e)),
      );
    }
    return employees;
  }

  Future<Employees?> getEmployeeById(String id) async {
    Response<Map<String, dynamic>> response = await dio.get(
      '/api/employees/$id',
    );
    if (response.data != null) {
      return Employees.fromJson(response.data!);
    }
    return null;
  }

  Future<Employees?> updateEmployee(String id, Employees employee) async {
    Response<Map<String, dynamic>> response = await dio.put(
      '/api/employees/$id',
      data: employee.toJson(),
    );
    if (response.data != null) {
      return Employees.fromJson(response.data!);
    }
    return null;
  }

  Future<Employees?> addNewEmployee(Employees employee) async {
    Response<Map<String, dynamic>> response = await dio.post(
      '/api/employees',
      data: employee.toJson(),
    );
    if (response.data != null) {
      return Employees.fromJson(response.data!);
    }
    return null;
  }

  Future<bool> deleteEmployee(String id) async {
    Response response = await dio.delete('/api/employees/$id');
    return response.statusCode == 200;
  }
}