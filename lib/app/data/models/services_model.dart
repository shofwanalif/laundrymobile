import 'package:hive/hive.dart';

part 'services_model.g.dart';

@HiveType(typeId: 0)
class ServicesModel {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String serviceName;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int price;

  @HiveField(4)
  final DateTime? createdAt;

  @HiveField(5)
  final DateTime? updatedAt;

  @HiveField(6)
  final String? imageUrl;

  ServicesModel({
    this.id,
    required this.serviceName,
    required this.description,
    required this.price,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ServicesModel.fromJson(Map<String, dynamic> json) {
    return ServicesModel(
      id: json['id'] as int?,
      serviceName: json['service_name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForInsert() {
    return {
      'service_name': serviceName,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'service_name': serviceName,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ServicesModel copyWith({
    int? id,
    String? serviceName,
    String? description,
    int? price,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServicesModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
