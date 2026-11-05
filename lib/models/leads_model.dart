class Leads {
  String id;
  String fullName;
  String phoneNumber;
  String email;
  String source;
  String status;
  String assignedEmployeeId;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;

  Leads({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.source,
    required this.status,
    required this.assignedEmployeeId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory Leads.fromJson(Map<String, dynamic> json) {
    return Leads(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      source: json['source'],
      status: json['status'],
      assignedEmployeeId: json['assignedEmployeeId'],
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
      'source': source,
      'status': status,
      'assignedEmployeeId': assignedEmployeeId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}
