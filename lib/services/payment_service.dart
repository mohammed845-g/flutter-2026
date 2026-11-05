import 'package:dio/dio.dart';
import 'package:flutter_application_5/models/payments_model.dart';

class PaymentApiService {
  late Dio dio;
  PaymentApiService() {
    dio = Dio(BaseOptions(baseUrl: "http://192.168.1.11:3000"));
  }
  Future<List<Payments>> getAllPayments() async {
    Response<List> response = await dio.get('/api/payments');
    List<Payments> payments = [];
    if (response.data != null) {
      payments = List<Payments>.from(
        response.data!.map((e) => Payments.fromJson(e)),
      );
    }
    return payments;
  }

  Future<Payments?> getPaymentById(String id) async {
    Response<Map<String, dynamic>> response = await dio.get(
      '/api/payments/$id',
    );
    if (response.data != null) {
      return Payments.fromJson(response.data!);
    }
    return null;
  }

  Future<Payments?> updatePayment(String id, Payments payment) async {
    Response<Map<String, dynamic>> response = await dio.put(
      '/api/payments/$id',
      data: payment.toJson(),
    );
    if (response.data != null) {
      return Payments.fromJson(response.data!);
    }
    return null;
  }

  Future<Payments?> addNewPayment(Payments payment) async {
    Response<Map<String, dynamic>> response = await dio.post(
      '/api/payments',
      data: payment.toJson(),
    );
    if (response.data != null) {
      return Payments.fromJson(response.data!);
    }
    return null;
  }

  Future<bool> deletePayment(String id) async {
    Response response = await dio.delete('/api/payments/$id');
    return response.statusCode == 200;
  }
}
