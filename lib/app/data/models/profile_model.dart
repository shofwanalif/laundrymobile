import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 0)
class ProfileModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? phone;

  @HiveField(3)
  String role;

  ProfileModel({
    required this.id,
    required this.name,
    this.phone,
    required this.role,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      name: map['name'] ?? '',
      phone: map['phone'],
      role: map['role'] ?? 'user',
    );
  }
}
