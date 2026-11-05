import 'package:dio/dio.dart';
import 'package:flutter_application_5/models/deals_model.dart';
class DealApiService {
  late Dio dio;
  DealApiService() {
    dio = Dio(BaseOptions(baseUrl: "http://192.168.1.11:3000"));
  }
  Future<List<Deals>> getAllDeals() async {
    Response<List> response = await dio.get('/api/deals');
    List<Deals> deals = [];
    if (response.data != null) {
      deals = List<Deals>.from(response.data!.map((e) => Deals.fromJson(e)));
    }
    return deals;
  }

  Future<Deals?> getDealById(String id) async {
    Response<Map<String, dynamic>> response = await dio.get('/api/deals/$id');
    if (response.data != null) {
      return Deals.fromJson(response.data!);
    }
    return null;
  }

  Future<Deals?> updateDeal(String id, Deals deal) async {
    Response<Map<String, dynamic>> response = await dio.put(
      '/api/deals/$id',
      data: deal.toJson(),
    );
    if (response.data != null) {
      return Deals.fromJson(response.data!);
    }
    return null;
  }

  Future<Deals?> addNewDeal(Deals deal) async {
    Response<Map<String, dynamic>> response = await dio.post(
      '/api/deals',
      data: deal.toJson(),
    );
    if (response.data != null) {
      return Deals.fromJson(response.data!);
    }
    return null;
  }

  Future<bool> deleteDeal(String id) async {
    Response response = await dio.delete('/api/deals/$id');
    return response.statusCode == 200;
  }
}