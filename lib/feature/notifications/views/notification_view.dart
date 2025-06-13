import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/feature/notifications/controller/notification_controller.dart';


class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      body: Center(child: Text('Team')),
    );
  }
}