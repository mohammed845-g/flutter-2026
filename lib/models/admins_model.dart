class Admins {
  String id;
  String name;
  String ssn;
  String phone;
  String email;
  String passwordHash;
  String role;
  DateTime createdAt;
  DateTime updatedAt;
  int? v;

  Admins({
    required this.id,
    required this.name,
    required this.ssn,
    required this.phone,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.v,
  });

  factory Admins.fromJson(Map<String, dynamic> json) {
    return Admins(
      id: json['_id'],
      name: json['name'],
      ssn: json['ssn'],
      phone: json['phone'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ssn': ssn,
      'phone': phone,
      'email': email,
      'passwordHash': passwordHash,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}