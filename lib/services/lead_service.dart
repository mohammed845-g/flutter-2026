import 'package:dio/dio.dart';
import 'package:flutter_application_5/models/leads_model.dart';
class LeadApiService {
  late Dio dio;
  LeadApiService() {
    dio = Dio(BaseOptions(baseUrl: "http://192.168.1.11:3000"));
  }
  Future<List<Leads>> getAllLeads() async {
    Response<List> response = await dio.get('/api/leads');
    List<Leads> leads = [];
    if (response.data != null) {
      leads = List<Leads>.from(response.data!.map((e) => Leads.fromJson(e)));
    }
    return leads;
  }

  Future<Leads?> getLeadById(String id) async {
    Response<Map<String, dynamic>> response = await dio.get('/api/leads/$id');
    if (response.data != null) {
      return Leads.fromJson(response.data!);
    }
    return null;
  }

  Future<Leads?> updateLead(String id, Leads lead) async {
    Response<Map<String, dynamic>> response = await dio.put(
      '/api/leads/$id',
      data: lead.toJson(),
    );
    if (response.data != null) {
      return Leads.fromJson(response.data!);
    }
    return null;
  }

  Future<Leads?> addNewLead(Leads lead) async {
    Response<Map<String, dynamic>> response = await dio.post(
      '/api/leads',
      data: lead.toJson(),
    );
    if (response.data != null) {
      return Leads.fromJson(response.data!);
    }
    return null;
  }

  Future<bool> deleteLead(String id) async {
    Response response = await dio.delete('/api/leads/$id');
    return response.statusCode == 200;
  }
}
