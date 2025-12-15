import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/notification_log_model.dart';

class LocalStorageService extends GetxService {
  static const String todoBoxName = 'todo_box';
  static const String notificationBoxName = 'notification_log_box';

  late final Box<NotificationLogModel> _notificationBox;

  Box<NotificationLogModel> get notificationBox => _notificationBox;

  Future<LocalStorageService> init() async {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDir.path);
    }

    if (!Hive.isAdapterRegistered(NotificationLogModelAdapter().typeId)) {
      Hive.registerAdapter(NotificationLogModelAdapter());
    }

    _notificationBox = await Hive.openBox<NotificationLogModel>(
      notificationBoxName,
    );

    return this;
  }
}
