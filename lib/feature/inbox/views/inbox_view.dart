import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/feature/inbox/controller/inbox_controller.dart';



class InboxView extends GetView<InboxController> {
  const InboxView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      body: Center(child: Text('Inbox')),
    );
  }
}