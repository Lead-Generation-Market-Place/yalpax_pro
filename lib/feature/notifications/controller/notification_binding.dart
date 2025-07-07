import 'package:get/get.dart';
import 'package:yalpax_pro/feature/notifications/controller/notification_controller.dart';

class TeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
