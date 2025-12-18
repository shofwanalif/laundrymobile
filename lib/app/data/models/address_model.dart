import 'package:hive/hive.dart';

part 'address_model.g.dart';

@HiveType(typeId: 1)
class AddressModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String label;

  @HiveField(3)
  String address;

  @HiveField(4)
  bool isDefault;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    required this.isDefault,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'],
      userId: map['user_id'],
      label: map['label'] ?? '',
      address: map['address'],
      isDefault: map['is_default'] ?? false,
    );
  }
}
