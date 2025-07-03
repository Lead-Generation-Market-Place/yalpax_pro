import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_flutter_toast.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class Ninthstep extends GetView<AuthController> {
  const Ninthstep({super.key});

  @override
  Widget build(BuildContext context) {
    final FocusNode _introFocusNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Introduce Your Business",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 1.0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tell customers about your business",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.businessDetailsInfo,
                  focusNode: _introFocusNode,
                  maxLines: 8,
                  minLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText:
                        "Describe your business, expertise, and what makes you unique...",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  style: TextStyle(color: Colors.grey[800]),
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${controller.businessDetailsInfo.text.length}/500",
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.businessDetailsInfo.text.length < 40
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                    Text(
                      "Minimum 40 characters",
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.businessDetailsInfo.text.length < 40
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  "EXAMPLE INTRODUCTIONS",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildExampleCard(
                  "My focus is quality. I never cut corners, even when it's more expensive. Some of my competitors are cheaper, but I will take the time to make sure you're 100% happy.",
                ),
                const SizedBox(height: 16),
                _buildExampleCard(
                  "I've been doing this for a really long time and I know how to get your home exactly what it needs. I'll make sure to leave a note after each visit with references.",
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You can mention:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBulletPoint("Years in business"),
                      _buildBulletPoint("What you're passionate about"),
                      _buildBulletPoint("Special skills or equipment"),
                      _buildBulletPoint("Your unique approach"),
                      _buildBulletPoint("Customer service philosophy"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          return CustomButton(
            text: 'Continue',
            isLoading: controller.isLoading.value,
            onPressed: () async {
              await controller.registerUser();
            },
          );
        }),
      ),
    );
  }

  Widget _buildExampleCard(String text) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: Colors.grey[800], height: 1.5)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.circle, size: 8, color: AppColors.info),
          ),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
