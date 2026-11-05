import 'package:dio/dio.dart';
import 'package:flutter_application_5/models/customers_model.dart';
class CustomerApiService {
  late Dio dio;
  CustomerApiService() {
    dio = Dio(BaseOptions(baseUrl: "http://192.168.1.11:3000"));
  }
  Future<List<Customers>> getAllCustomers() async {
    Response<List> response = await dio.get('/api/customers');
    List<Customers> customers = [];
    if (response.data != null) {
      customers = List<Customers>.from(
        response.data!.map((e) => Customers.fromJson(e)),
      );
    }
    return customers;
  }

  Future<Customers?> getCustomerById(String id) async {
    Response<Map<String, dynamic>> response = await dio.get(
      '/api/customers/$id',
    );
    if (response.data != null) {
      return Customers.fromJson(response.data!);
    }
    return null;
  }

  Future<Customers?> updateCustomer(String id, Customers customer) async {
    Response<Map<String, dynamic>> response = await dio.put(
      '/api/customers/$id',
      data: customer.toJson(),
    );
    if (response.data != null) {
      return Customers.fromJson(response.data!);
    }
    return null;
  }

  Future<Customers?> addNewCustomer(Customers customer) async {
    Response<Map<String, dynamic>> response = await dio.post(
      '/api/customers',
      data: customer.toJson(),
    );
    if (response.data != null) {
      return Customers.fromJson(response.data!);
    }
    return null;
  }

  Future<bool> deleteCustomer(String id) async {
    Response response = await dio.delete('/api/customers/$id');
    return response.statusCode == 200;
  }
}