class LaundryService {
  final String id;
  final String serviceName;
  final String description;
  final int price;

  LaundryService({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.price,
  });

  factory LaundryService.fromJson(Map<String, dynamic> json) {
    return LaundryService(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'description': description,
      'price': price,
    };
  }
}
