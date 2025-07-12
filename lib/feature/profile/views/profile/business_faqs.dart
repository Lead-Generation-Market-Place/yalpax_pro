import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class BusinessFaqs extends GetView<ProfileController> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (!controller.hasLoadedFaqs) {
      controller.fetchAnsweredBusinessFaqs();
      controller.hasLoadedFaqs = true;
    }

    String? validateMin50IfTyped(String? value) {
      if (value != null && value.trim().isNotEmpty && value.trim().length < 50) {
        return 'Please enter at least 50 characters';
      }
      return null;
    }

    Widget buildQuestion({
      required String title,
      required TextEditingController controllerText,
      required RxBool hasTyped,
      required RxInt charCount,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CustomInput(
            controller: controllerText,
            maxLines: null,
            validator: validateMin50IfTyped,
          ),
          Obx(() {
            final typed = hasTyped.value;
            final length = charCount.value;
            final remaining = 50 - length;

            if (!typed) {
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Minimum 50 characters needed',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              );
            } else if (remaining > 0) {
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$remaining more characters needed',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          const SizedBox(height: 20),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business FAQs'),
        actions: [
          CustomButton(
            text: 'Save',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Get.defaultDialog(
                  title: 'Confirm Save',
                  middleText: 'Are you sure you want to save your answers?',
                  textConfirm: 'Yes',
                  textCancel: 'No',
                  confirmTextColor: Colors.white,
                  onConfirm: () async {
                    Get.back(); // Close dialog
                    await controller.answeredBusinessFaqsQuestion(); // Save method
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildQuestion(
                title: 'What should the customer know about your pricing (e.g., discounts, fees)?',
                controllerText: controller.firstBusinessQuestion,
                hasTyped: controller.hasTypedFirstBusiness,
                charCount: controller.firstBusinessCharCount,
              ),
              buildQuestion(
                title: 'What is your typical process for working with a new customer?',
                controllerText: controller.secondtBusinessQuestion,
                hasTyped: controller.hasTypedSecondBusiness,
                charCount: controller.secondBusinessCharCount,
              ),
              buildQuestion(
                title: 'What education and/or training do you have that relates to your work?',
                controllerText: controller.thirdBusinessQuestion,
                hasTyped: controller.hasTypedThirdBusiness,
                charCount: controller.thirdBusinessCharCount,
              ),
              buildQuestion(
                title: 'How did you get started doing this type of work?',
                controllerText: controller.fourthBusinessQuestion,
                hasTyped: controller.hasTypedFourthBusiness,
                charCount: controller.fourthBusinessCharCount,
              ),
              buildQuestion(
                title: 'What type of customer have you worked with?',
                controllerText: controller.fifthBusinessQuestion,
                hasTyped: controller.hasTypedFifthBusiness,
                charCount: controller.fifthBusinessCharCount,
              ),
              buildQuestion(
                title: 'Describe a recent project you are fond of. How long did it take?',
                controllerText: controller.sixthBusinessQuestion,
                hasTyped: controller.hasTypedSixthBusiness,
                charCount: controller.sixthBusinessCharCount,
              ),
              buildQuestion(
                title: 'What advice you would give a customer looking to hire a provider in your area of work?',
                controllerText: controller.seventhBusinessQuestion,
                hasTyped: controller.hasTypedSeventhBusiness,
                charCount: controller.seventhBusinessCharCount,
              ),
              buildQuestion(
                title: 'What questions should customers think through before talking to professionals about their project?',
                controllerText: controller.eightBusinessQuestion,
                hasTyped: controller.hasTypedEighthBusiness,
                charCount: controller.eighthBusinessCharCount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
