class Deals {
  String id;
  String customerId;
  String unitId;
  String employeeId;
  String dealType;
  String dealStatus;
  int totalAmount;
  String paymentMethod;
  int downPayment;
  int remainingAmount;
  DateTime contractDate;
  DateTime createdAt;
  DateTime updatedAt;

  Deals({
    required this.id,
    required this.customerId,
    required this.unitId,
    required this.employeeId,
    required this.dealType,
    required this.dealStatus,
    required this.totalAmount,
    required this.paymentMethod,
    required this.downPayment,
    required this.remainingAmount,
    required this.contractDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Deals.fromJson(Map<String, dynamic> json) {
    return Deals(
      id: json['_id'],
      customerId: json['customerId'],
      unitId: json['unitId'],
      employeeId: json['employeeId'],
      dealType: json['dealType'],
      dealStatus: json['dealStatus'],
      totalAmount: json['totalAmount'],
      paymentMethod: json['paymentMethod'],
      downPayment: json['downPayment'],
      remainingAmount: json['remainingAmount'],
      contractDate: DateTime.parse(json['contractDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerId': customerId,
      'unitId': unitId,
      'employeeId': employeeId,
      'dealType': dealType,
      'dealStatus': dealStatus,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'downPayment': downPayment,
      'remainingAmount': remainingAmount,
      'contractDate': contractDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
