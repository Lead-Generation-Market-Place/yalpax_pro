import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class Twelvthstep extends GetView<AuthController> {
  const Twelvthstep({super.key});

  @override
  Widget build(BuildContext context) {
    // Open bottom sheet on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showBottomSheet(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Request reviews"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 1.0, // 100%
            backgroundColor: Colors.grey[200],
            color: Colors.lightBlue,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, color: Colors.black),
                children: [
                  TextSpan(text: "Pros with reviews are "),
                  TextSpan(
                    text: "5 times ",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: "as likely to get hired."),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(Icons.g_mobiledata, "Import from Google"),
            const Divider(),
            _buildOptionTile(Icons.chat_bubble_outline, "Text past customers"),
            const Divider(),
            _buildOptionTile(Icons.email_outlined, "Email past customers"),
            const Divider(),
            _buildOptionTile(Icons.share, "Other sharing options"),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // TODO: Implement actions
      },
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drag_handle, size: 24, color: Colors.grey),
              const SizedBox(height: 16),
              const Icon(Icons.star_rate_rounded, size: 50, color: Colors.blue),
              const SizedBox(height: 12),
              const Text(
                "Reviews are important to get leads.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Customers are unlikely to see you in search results without at least 1 review.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Add logic to go back to review step
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Go back and add review"),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Continue without review
                  Get.toNamed(Routes.thirteenStep);
                },
                child: const Text("Do it later"),
              ),
            ],
          ),
        );
      },
    );
  }
}
