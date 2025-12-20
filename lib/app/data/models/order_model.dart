import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'order_model.g.dart';

@HiveType(typeId: 3)
class OrderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String serviceId;

  @HiveField(3)
  double weight;

  @HiveField(4)
  int totalPrice;

  @HiveField(5)
  String status;

  @HiveField(6)
  String? note;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? updatedAt;

  // Menambahkan field addressId dengan index HiveField baru
  @HiveField(9)
  String? addressId;

  OrderModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.weight,
    required this.totalPrice,
    required this.status,
    this.note,
    required this.createdAt,
    this.updatedAt,
    this.addressId, // Tambahkan di constructor
  });

  /// FROM SUPABASE
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      userId: map['user_id'],
      serviceId: map['service_id'],
      weight: (map['weight'] ?? 0).toDouble(),
      totalPrice: map['total_price'],
      status: map['status'],
      note: map['note'],
      addressId: map['address_id'], // Map dari kolom database
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  /// INSERT KE SUPABASE
  Map<String, dynamic> toJsonForInsert() {
    return {
      'user_id': userId,
      'service_id': serviceId,
      'address_id': addressId, // Tambahkan untuk insert
      'weight': weight,
      'total_price': totalPrice,
      'status': status,
      'note': note,
    };
  }

  /// UPDATE (ADMIN / STATUS)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'weight': weight,
      'total_price': totalPrice,
      'status': status,
      'note': note,
      'address_id': addressId, // Tambahkan jika address bisa diubah
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  OrderModel copyWith({
    double? weight,
    int? totalPrice,
    String? status,
    String? note,
    DateTime? updatedAt,
    String? addressId, // Tambahkan di copyWith
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      serviceId: serviceId,
      weight: weight ?? this.weight,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addressId: addressId ?? this.addressId,
    );
  }
}

extension OrderModelX on OrderModel {
  String get formattedCreatedAt {
    return DateFormat(
      'dd MMM yyyy, HH:mm',
      'id_ID',
    ).format(createdAt);
  }
}