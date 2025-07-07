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
      body: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Search field
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Messages'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
