import 'package:hive/hive.dart';

part 'service_model.g.dart';

@HiveType(typeId: 2)
class ServiceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  int pricePerKg;

  @HiveField(4)
  String duration;

  @HiveField(5)
  String? imageUrl;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerKg,
    required this.duration,
    this.imageUrl,
  });

  /// Dari Supabase (select)
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] ?? '',
      pricePerKg: map['price_per_kg'] as int,
      duration: map['duration'] as String,
      imageUrl: map['image_url'] as String?,
    );
  }

  /// Untuk insert ke Supabase (tanpa id)
  Map<String, dynamic> toMapForInsert() {
    return {
      'name': name,
      'description': description,
      'price_per_kg': pricePerKg,
      'duration': duration,
      'image_url': imageUrl,
    };
  }

  /// Untuk update ke Supabase
  Map<String, dynamic> toMapForUpdate() {
    return {
      'name': name,
      'description': description,
      'price_per_kg': pricePerKg,
      'duration': duration,
      'image_url': imageUrl,
    };
  }

  /// Untuk Hive (opsional, kalau mau serialize manual)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_per_kg': pricePerKg,
      'duration': duration,
      'image_url': imageUrl,
    };
  }

  /// Copy object (berguna untuk update UI)
  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    int? pricePerKg,
    String? duration,
    String? imageUrl,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      duration: duration ?? this.duration,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
