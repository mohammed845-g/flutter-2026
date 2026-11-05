class Units {
  Location location;
  String id;
  String title;
  String description;
  String type;
  String status;
  int price;
  int area;
  int bedrooms;
  int bathrooms;
  int floor;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;

  Units({
    required this.location,
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.price,
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    required this.floor,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory Units.fromJson(Map<String, dynamic> json) {
    return Units(
      location: Location.fromJson(json['location']),
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      status: json['status'],
      price: json['price'],
      area: json['area'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      floor: json['floor'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isDeleted: json['isDeleted'],
    );
  }
Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'price': price,
      'area': area,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'floor': floor,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

}

class Location {
  String city;
  String area;
  String developer;

  Location({required this.city, required this.area, required this.developer});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'],
      area: json['area'],
      developer: json['developer'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'area': area,
      'developer': developer,
    };
  }
}
