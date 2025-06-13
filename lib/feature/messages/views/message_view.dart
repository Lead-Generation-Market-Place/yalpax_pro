import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/core/widgets/foldable_widgets.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';
import 'package:yalpax_pro/feature/messages/controllers/messages_controller.dart';


class MessageView extends GetView<MessagesController> {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
 

    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      
    );
  }
}