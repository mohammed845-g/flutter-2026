import 'package:dio/dio.dart';
import 'package:flutter_application_5/models/units_model.dart';

class UnitApiService {
  late Dio dio;
  UnitApiService() {
    dio = Dio(BaseOptions(baseUrl: "http://192.168.1.11:3000"));
  }
  Future<List<Units>> getAllUnits() async {
    Response<List> response = await dio.get('/api/units');
    List<Units> units = [];
    if (response.data != null) {
      units = List<Units>.from(response.data!.map((e) => Units.fromJson(e)));
    }
    return units;
  }
  Future<Units?> getUnitById(String id) async {
    Response<Map<String, dynamic>> response = await dio.get('/api/units/$id');
    if (response.data != null) {
      return Units.fromJson(response.data!);
    }
    return null;
  }
  Future<Units?> updateUnit(String id, Units unit) async {
    Response<Map<String, dynamic>> response = await dio.put(
      '/api/units/$id',
      data: unit.toJson(),
    );
    if (response.data != null) {
      return Units.fromJson(response.data!);
    }
    return null;
  }
  Future<Units?> addNewUnit(Units unit) async {
    Response<Map<String, dynamic>> response = await dio.post(
      '/api/units',
      data: unit.toJson(),
    );
    if (response.data != null) {
      return Units.fromJson(response.data!);
    }
    return null;
  }
  Future<bool> deleteUnit(String id) async {
    Response response = await dio.delete('/api/units/$id');
    return response.statusCode == 200;
  }
}
