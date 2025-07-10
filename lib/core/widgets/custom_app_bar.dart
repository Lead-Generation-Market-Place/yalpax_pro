import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showSetupBanner;
  final double horizontalPadding;
  final VoidCallback? onBack; 
  const CustomAppBar({
    super.key,
    this.title = '',
    this.actions,
    this.showBackButton = false,
    this.showSetupBanner = true,
    this.horizontalPadding = 16.0,
     this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final JobsController jobsController = Get.find<JobsController>();
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSetupBanner)
          Obx(() {
            if (jobsController.isLoading.value) {
              return const SizedBox.shrink();
            }

            if (jobsController.isCount.value >= 3) {
              return const SizedBox.shrink();
            }

            return Material(
              // color: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: 12 + statusBarHeight, // Account for status bar
                  bottom: 12,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 400;
                    return isSmallScreen
                        ? _buildSmallScreenBanner(jobsController, context)
                        : _buildNormalBanner(jobsController, context);
                  },
                ),
              ),
            );
          }),
        SizedBox(height: 2),
        AppBar(
          title: Text(title),
          centerTitle: false,
          automaticallyImplyLeading: false, // 👈 Prevent default back button
          leading: showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed:
                      onBack ??
                      () => Get.back(), // 👈 Use passed function or default
                )
              : null,
          elevation: 0,
          scrolledUnderElevation: 4,
          // backgroundColor: Colors.blue[100],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          toolbarHeight: kToolbarHeight,
        ),
      ],
    );
  }

  Widget _buildNormalBanner(
    JobsController jobsController,
    BuildContext context,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: jobsController.isCount.value / 3,
            backgroundColor: AppColors.neutral200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Only ${3 - jobsController.isCount.value} setup remained',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue[900],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            await Get.toNamed(Routes.finishSetup);
            jobsController.checkStep();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Finish setup',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenBanner(
    JobsController jobsController,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                value: jobsController.isCount.value / 3,
                backgroundColor: AppColors.neutral200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${3 - jobsController.isCount.value} setup remaining',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await Get.toNamed(Routes.finishSetup);
              jobsController.checkStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue100,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Finish setup',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize {
    final JobsController jobsController = Get.find<JobsController>();
    final hasBanner =
        showSetupBanner &&
        !jobsController.isLoading.value &&
        jobsController.isCount.value < 3;

    // Overestimate banner height safely
    const estimatedBannerHeight = 130;

    return Size.fromHeight(
      kToolbarHeight + (hasBanner ? estimatedBannerHeight : 0),
    );
  }
}
