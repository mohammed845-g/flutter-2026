import 'package:dio/dio.dart';
import 'package:flutter_application_5/models/admins_model.dart';

class AdminApiService {
  late Dio dio;
  AdminApiService() {
    dio = Dio(BaseOptions(baseUrl: "http://192.168.1.11:3000"));
  }
  Future<List<Admins>> getAllAdmins() async {
    Response<List> response = await dio.get('/api/admins');
    List<Admins> admins = [];
    if (response.data != null) {
      admins = List<Admins>.from(response.data!.map((e) => Admins.fromJson(e)));
    }
    return admins;
  }

  Future<Admins?> getAdminById(String id) async {
    Response<Map<String, dynamic>> response = await dio.get('/api/admins/$id');
    if (response.data != null) {
      return Admins.fromJson(response.data!);
    }
    return null;
  }

  Future<Admins?> updateAdmin(String id, Admins admin) async {
    Response<Map<String, dynamic>> response = await dio.put(
      '/api/admins/$id',
      data: admin.toJson(),
    );
    if (response.data != null) {
      return Admins.fromJson(response.data!);
    }
    return null;
  }

  Future<Admins?> addNewAdmin(Admins admin) async {
    Response<Map<String, dynamic>> response = await dio.post(
      '/api/admins',
      data: admin.toJson(),
    );
    if (response.data != null) {
      return Admins.fromJson(response.data!);
    }
    return null;
  }

  Future<bool> deleteAdmin(String id) async {
    Response response = await dio.delete('/api/admins/$id');
    return response.statusCode == 200;
  }
}