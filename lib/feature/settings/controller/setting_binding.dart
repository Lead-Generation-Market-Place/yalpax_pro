import 'package:get/get.dart';
import 'package:yalpax_pro/feature/settings/controller/setting_controller.dart';



class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
} 