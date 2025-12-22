import 'package:hive/hive.dart';

part 'notification_log_model.g.dart';

@HiveType(typeId: 4)
class NotificationLogModel extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String body;

  @HiveField(2)
  late DateTime timestamp;

  @HiveField(3)
  late String type; // "push" or "local"

  NotificationLogModel({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
  });
}
