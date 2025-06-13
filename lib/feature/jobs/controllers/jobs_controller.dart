import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class jobsController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();

  }

 
}
