import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';

class Thirteenstep extends GetView<AuthController> {
  const Thirteenstep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Open bottom sheet on first frame
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!controller.bottomSheetShown.value) {
    //     showBottomSheet(context);
    //     controller.bottomSheetShown.value = true;
    //   }
    // });

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          "Request Reviews",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn().slideX(),
        elevation: 0,
        backgroundColor: colors.background,
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onBackground,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: "Pros with reviews are "),
                          TextSpan(
                            text: "5× more likely\n",
                            style: TextStyle(
                              color: AppColors.info,
                              fontWeight: FontWeight.bold,
                              fontSize: theme.textTheme.titleLarge?.fontSize,
                            ),
                          ),
                          const TextSpan(text: "to get hired"),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.star_rate_rounded,
                    size: 48,
                    color: AppColors.info,
                  ).animate()
                    .scale(delay: 300.ms)
                    .then()
                    .shake(delay: 600.ms),
                ],
              ),
            ).animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 32),

            Text(
              "Choose how to get reviews",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onBackground.withOpacity(0.7),
              ),
            ).animate()
              .fadeIn(delay: 400.ms)
              .slideX(),

            const SizedBox(height: 16),

            // Options list
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: colors.surface,
                  elevation: 0,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildOptionTile(
                        context,
                        icon: Icons.g_mobiledata,
                        title: "Import from Google",
                        subtitle: "Import your existing Google reviews",
                        color: const Color(0xFFEA4335),
                      ).animate()
                        .fadeIn(delay: 500.ms)
                        .slideX(),
                      _buildOptionTile(
                        context,
                        icon: Icons.chat_bubble_outline,
                        title: "Text past customers",
                        subtitle: "Send SMS review requests",
                        color: const Color(0xFF34A853),
                      ).animate()
                        .fadeIn(delay: 600.ms)
                        .slideX(),
                      _buildOptionTile(
                        context,
                        icon: Icons.email_outlined,
                        title: "Email past customers",
                        subtitle: "Send email review invitations",
                        color: const Color(0xFF4285F4),
                        route: Routes.reviews,
                      ).animate()
                        .fadeIn(delay: 700.ms)
                        .slideX(),
                      _buildOptionTile(
                        context,
                        icon: Icons.share_outlined,
                        title: "Share review link",
                        subtitle: "Share your review link anywhere",
                        color: const Color(0xFF9C27B0),
                      ).animate()
                        .fadeIn(delay: 800.ms)
                        .slideX(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: 'Skip for now',
              onPressed: () {
                final jobsController = Get.find<JobsController>();
                jobsController.navigateToJobs();
              },
              key: CustomButton.styleFrom(
                backgroundColor: colors.surface,
                foregroundColor: colors.primary,
                elevation: 0,
                side: BorderSide(color: colors.primary.withOpacity(0.2)),
              ),
            ).animate()
              .fadeIn(delay: 900.ms)
              .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    String? route,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (route != null) {
            Get.toNamed(route);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              // Leading icon with enhanced container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color?.withOpacity(0.1) ?? colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (color ?? colors.primary).withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: color ?? colors.onSurface, size: 28),
              ),
              const SizedBox(width: 20),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Animated trailing icon
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurface.withOpacity(0.5),
                size: 24,
              ),
            ],
          ),
        ),
      ),
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
    );
  }
}
