import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class Thirteenstep extends GetView<AuthController> {
  const Thirteenstep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Open bottom sheet on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.bottomSheetShown.value) {
        showBottomSheet(context);
        controller.bottomSheetShown.value = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Request Reviews",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
   
       
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 1.0,
            backgroundColor: colors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
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
              padding: const EdgeInsets.all(20),
             
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                  children: [
                    const TextSpan(text: "Pros with reviews are "),
                    TextSpan(
                      text: "5× more likely ",
                      style: TextStyle(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: "to get hired"),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: IconButton(
                        onPressed: () {
                          Get.toNamed(Routes.reviews);
                        },
                        icon: const Icon(Icons.email),
                        color: AppColors.info,
                        padding: const EdgeInsets.only(left: 4),
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                        splashRadius: 20,
                        tooltip: "Email",
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Options list
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: colors.surface,
                  elevation: 0,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildOptionTile(
                        context,
                        icon: Icons.g_mobiledata,
                        title: "Import from Google",
                        color: const Color(0xFFEA4335), // Google red
                      ),
                      const Divider(height: 1, indent: 72, endIndent: 16),
                      _buildOptionTile(
                        context,
                        icon: Icons.chat_bubble_outline,
                        title: "Text past customers",
                        color: const Color(0xFF34A853), // Google green
                      ),
                      const Divider(height: 1, indent: 72, endIndent: 16),
                      _buildOptionTile(
                        context,
                        icon: Icons.email_outlined,
                        title: "Email past customers",
                        color: const Color(0xFF4285F4), // Google blue
                      ),
                      const Divider(height: 1, indent: 72, endIndent: 16),
                      _buildOptionTile(
                        context,
                        icon: Icons.share_outlined,
                        title: "Share review link",
                        color: const Color(0xFF9C27B0), // Purple
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: CustomButton(
                text: 'Continue',
                onPressed: () => Get.toNamed(Routes.jobs),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? colors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? colors.onSurface, size: 24),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colors.onSurface.withOpacity(0.3),
      ),
      onTap: () {
        // TODO: Implement actions
      },
    );
  }

  void showBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Icon
              // Container(
              //   width: 80,
              //   height: 80,
           
              //   child: Icon(
              //     Icons.star_rate_rounded,
              //     size: 40,
              //     color: AppColors.info,
              //   ),
              // ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                "Reviews Boost Your Visibility",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Profiles with reviews appear higher in search results and get 5× more leads than those without. Adding just one review can significantly improve your visibility.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Primary button
              CustomButton(
                text: 'Add Reviews Now',
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.back();
                },
              ),
              const SizedBox(height: 16),
              
              // Secondary option
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.toNamed(Routes.jobs);
                },
                child: Text(
                  "I'll do this later",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) => controller.bottomSheetShown.value = false);
  }
}