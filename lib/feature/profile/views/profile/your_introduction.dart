import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class YourIntroduction extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your introduction', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Save Introduction'),
                    content: Text('Do you want to save your business introduction?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Yes'),
                      ),
                    ],
                  );
                },
              );
              
              if (result == true) {
                await controller.saveBusinessIntroduction();
              }
            },
            label: Text('Save', style: TextStyle(color:Colors.white)),
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CustomInput(
              controller: controller.introductionController,
              autofocus: true,
              label: 'Tell customers about your business',
            ),
            const SizedBox(height: 30),
            const Text(
              "Explain what makes your business stand out and why you'll do a great job.",
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
