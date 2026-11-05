class Employees {
  String id;
  String fullName;
  String phoneNumber;
  String email;
  String passwordHash;
  String department;
  String role;
  DateTime hireDate;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;

  Employees({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.passwordHash,
    required this.department,
    required this.role,
    required this.hireDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory Employees.fromJson(Map<String, dynamic> json) {
    return Employees(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      department: json['department'],
      role: json['role'],
      hireDate: DateTime.parse(json['hireDate']),
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
      'passwordHash': passwordHash,
      'department': department,
      'role': role,
      'hireDate': hireDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}
