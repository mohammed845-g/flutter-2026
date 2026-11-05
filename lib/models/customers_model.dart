class Customers {
  String id;
  String fullName;
  String phoneNumber;
  String email;
  String nationalId;
  String address;
  String ownedUnitsId;
  String assignedEmployeeId;
  String paymentStatus;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;

  Customers({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.nationalId,
    required this.address,
    required this.ownedUnitsId,
    required this.assignedEmployeeId,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory Customers.fromJson(Map<String, dynamic> json) {
    return Customers(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      nationalId: json['nationalId'],
      address: json['address'],
      ownedUnitsId: json['ownedUnitsId'],
      assignedEmployeeId: json['assignedEmployeeId'],
      paymentStatus: json['paymentStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'nationalId': nationalId,
      'address': address,
      'ownedUnitsId': ownedUnitsId,
      'assignedEmployeeId': assignedEmployeeId,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}
