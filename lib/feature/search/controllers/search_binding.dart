import 'package:get/get.dart';
import 'package:yalpax_pro/feature/search/controllers/search_controller.dart';


class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchController>(() => SearchController());
  }
}