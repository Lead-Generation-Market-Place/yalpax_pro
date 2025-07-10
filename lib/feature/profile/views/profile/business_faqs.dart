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
                    await controller
                        .answeredBusinessFaqsQuestion(); // Call the save method
                  },
                  onCancel: () {
                    // No need to call Get.back(); it closes automatically
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
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What should the customer know about your pricing (e.g., discounts, fees)?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomInput(
                controller: controller.firstBusinessQuestion,
                maxLines: null,
                validator: (value) {
                  // We don't show error text here — validation handled by message below
                  return null;
                },
              ),
              Obx(() {
                final hasTyped = controller.hasTypedFirstBusiness.value;
                final length = controller.firstBusinessCharCount.value;
                final remaining = 50 - length;

                // Always show message
                if (!hasTyped) {
                  // Before typing
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '50 characters needed',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  );
                } else if (remaining > 0) {
                  // While typing but not reached 50
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$remaining more characters needed',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                } else {
                  // 50 or more characters - no message
                  return const SizedBox.shrink();
                }
              }),
              ////////////////////////////////////////////////////////////////////////
              const SizedBox(height: 20),
              const Text(
                'What is your typical process for working with a new customer?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomInput(
                controller: controller.secondtBusinessQuestion,
                maxLines: null,
                validator: (value) {
                  // We don't show error text here — validation handled by message below
                  return null;
                },
              ),
              Obx(() {
                final hasTyped = controller.hasTypedSecondBusiness.value;
                final length = controller.secondBusinessCharCount.value;
                final remaining = 0 - length;

                // Always show message
                if (!hasTyped) {
                  // Before typing
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Minimum 0 characters needed',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  );
                } else if (remaining > 0) {
                  // While typing but not reached 50
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$remaining more characters needed',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                } else {
                  // 50 or more characters - no message
                  return const SizedBox.shrink();
                }
              }),
              ///////////////////////////////////////////////////////////////////////////////////////3
              const SizedBox(height: 20),
              const Text(
                'What education and/or training do you have that relates to your work?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomInput(
                controller: controller.thirdBusinessQuestion,
                maxLines: null,
                validator: (value) {
                  // We don't show error text here — validation handled by message below
                  return null;
                },
              ),
              Obx(() {
                final hasTyped = controller.hasTypedThirdBusiness.value;
                final length = controller.thirdBusinessCharCount.value;
                final remaining = 50 - length;

                // Always show message
                if (!hasTyped) {
                  // Before typing
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Minimum 50 characters needed',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  );
                } else if (remaining > 0) {
                  // While typing but not reached 50
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$remaining more characters needed',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                } else {
                  // 50 or more characters - no message
                  return const SizedBox.shrink();
                }
              }),

              const SizedBox(height: 20),
              ////////////////////////////////////////////4
              const SizedBox(height: 20),
              const Text(
                'How did you get started doing this type of work?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomInput(
                controller: controller.fourthBusinessQuestion,
                maxLines: null,
                validator: (value) {
                  // We don't show error text here — validation handled by message below
                  return null;
                },
              ),
              Obx(() {
                final hasTyped = controller.hasTypedFourthBusiness.value;
                final length = controller.fourthBusinessCharCount.value;
                final remaining = 50 - length;

                // Always show message
                if (!hasTyped) {
                  // Before typing
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Minimum 50 characters needed',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  );
                } else if (remaining > 0) {
                  // While typing but not reached 50
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$remaining more characters needed',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                } else {
                  // 50 or more characters - no message
                  return const SizedBox.shrink();
                }
              }),

              const SizedBox(height: 20),

              ///////////////////////////////////////////////////5
              const SizedBox(height: 20),
              const Text(
                'What type of customer have you worked with?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomInput(
                controller: controller.fifthBusinessQuestion,
                maxLines: null,
                validator: (value) {
                  // We don't show error text here — validation handled by message below
                  return null;
                },
              ),
              Obx(() {
                final hasTyped = controller.hasTypedFifthBusiness.value;
                final length = controller.fifthBusinessCharCount.value;
                final remaining = 50 - length;

                // Always show message
                if (!hasTyped) {
                  // Before typing
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Minimum 50 characters needed',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  );
                } else if (remaining > 0) {
                  // While typing but not reached 50
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$remaining more characters needed',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                } else {
                  // 50 or more characters - no message
                  return const SizedBox.shrink();
                }
              }),

              const SizedBox(height: 20),
              ///////////////////////////////////////////6
              const SizedBox(height: 20),
              const Text(
                'Describe a recent project you are fond of. How long did it take?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomInput(
                controller: controller.sixthBusinessQuestion,
                maxLines: null,
                validator: (value) {
                  // We don't show error text here — validation handled by message below
                  return null;
                },
              ),
              Obx(() {
                final hasTyped = controller.hasTypedSixthBusiness.value;
                final length = controller.sixthBusinessCharCount.value;
                final remaining = 50 - length;

                // Always show message
                if (!hasTyped) {
                  // Before typing
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Minimum 50 characters needed',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  );
                } else if (remaining > 0) {
                  // While typing but not reached 50
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$remaining more characters needed',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                } else {
                  // 50 or more characters - no message
                  return const SizedBox.shrink();
                }
              }),
              ////////////////////////////////////////////////////7
              const SizedBox(height: 20),
              const Text(
                'What advice you would give a customer looking to hire a provider in your area of work?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomInput(
                controller: controller.seventhBusinessQuestion,
                maxLines: null,
                validator: (value) {
                  // We don't show error text here — validation handled by message below
                  return null;
                },
              ),
              Obx(() {
                final hasTyped = controller.hasTypedSeventhBusiness.value;
                final length = controller.seventhBusinessCharCount.value;
                final remaining = 50 - length;

                // Always show message
                if (!hasTyped) {
                  // Before typing
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Minimum 50 characters needed',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  );
                } else if (remaining > 0) {
                  // While typing but not reached 50
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$remaining more characters needed',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                } else {
                  // 50 or more characters - no message
                  return const SizedBox.shrink();
                }
              }),

              const SizedBox(height: 20),

              ///////////////////////////////////////////8
              const Text(
                'What questions should customers think through before talking to professionals about their project?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CustomInput(
                controller: controller.eightBusinessQuestion,
                maxLines: null,
                validator: (value) {
                  // We don't show error text here — validation handled by message below
                  return null;
                },
              ),
              Obx(() {
                final hasTyped = controller.hasTypedEighthBusiness.value;
                final length = controller.eighthBusinessCharCount.value;
                final remaining = 50 - length;

                // Always show message
                if (!hasTyped) {
                  // Before typing
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Minimum 50 characters needed',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  );
                } else if (remaining > 0) {
                  // While typing but not reached 50
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$remaining more characters needed',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                } else {
                  // 50 or more characters - no message
                  return const SizedBox.shrink();
                }
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
