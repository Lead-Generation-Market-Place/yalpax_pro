import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class Eightstep extends GetView<AuthController> {
  const Eightstep({super.key});

  @override
  Widget build(BuildContext context) {
    // Open bottom sheet on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.bottomSheetShown.value) {
        showBottomSheet(context);
        controller.bottomSheetShown.value = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Request Reviews",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Get.back();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 1.0, // 100%
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with emphasized statistic
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[800]),
                  children: [
                    const TextSpan(text: "Pros with reviews are "),
                    TextSpan(
                      text: "5 times ",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: "more likely to get hired."),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Options list
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildOptionTile(
                    context,
                    icon: Icons.g_mobiledata,
                    title: "Import from Google",
                    color: Colors.red[400],
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildOptionTile(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: "Text past customers",
                    color: Colors.green[400],
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildOptionTile(
                    context,
                    icon: Icons.email_outlined,
                    title: "Email past customers",
                    color: Colors.blue[400],
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildOptionTile(
                    context,
                    icon: Icons.share_outlined,
                    title: "Other sharing options",
                    color: Colors.purple[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color?.withOpacity(0.2) ?? Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? Colors.grey[600], size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[500],
      ),
      onTap: () {
        // TODO: Implement actions
      },
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true, // Changed to true to allow dismissal
      enableDrag: true, // Changed to true to allow drag dismissal
      backgroundColor: Colors.transparent,
      builder: (_) {
        return PopScope(
          canPop: true, // Allow back button to dismiss
          onPopInvoked: (didPop) {
            if (didPop) {
              controller.bottomSheetShown.value = false;
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_rate_rounded,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Reviews Help You Get More Leads",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Customers are unlikely to see you in search results without at least one review. Adding reviews now will significantly improve your visibility.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], height: 1.5),
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Go Back and add Review',
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the bottom sheet
                    Get.back(); // Navigate back
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the bottom sheet
                    Get.toNamed(Routes.ninthStep);
                  },
                  child: Text(
                    "Do It Later",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      controller.bottomSheetShown.value = false;
    });
  }
}
