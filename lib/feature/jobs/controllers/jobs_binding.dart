import 'package:get/get.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';

class JobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<JobsController>(JobsController(), permanent: true);
   
  }
}
