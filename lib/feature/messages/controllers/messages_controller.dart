import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class MessagesController extends GetxController {
 
  final RxBool isLoading = false.obs;

  final SupabaseClient supabase = Supabase.instance.client;


  
}