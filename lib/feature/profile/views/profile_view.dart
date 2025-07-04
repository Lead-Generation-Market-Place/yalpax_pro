import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
   ProfileView({super.key});
  final AuthController authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      body: Center(child: CustomButton(text: 'Logout',onPressed: (){
            authController.signOut();
      },)),
    );
  }
}
