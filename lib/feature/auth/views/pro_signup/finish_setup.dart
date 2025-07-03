import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';


class FinishSetup extends GetView<AuthController> {
  const FinishSetup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _FinishSetupContent();
  }
}

class _FinishSetupContent extends StatefulWidget {
  @override
  State<_FinishSetupContent> createState() => _FinishSetupContentState();
}

class _FinishSetupContentState extends State<_FinishSetupContent> {
  final JobsController jobsController = Get.find<JobsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      jobsController.checkStep();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Finish Setup - Yalpax Pro',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Finish setup.',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: jobsController.isCount.value / 3,
                        backgroundColor: Colors.grey[200],
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Only ${3 - jobsController.isCount.value} setup tasks left before you can\nstart getting leads.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildTaskItem(
                  icon: Icons.check_circle,
                  text: 'Fill out your business profile.',
                  isCompleted: jobsController.isCount.value >= 1,
                  showArrow: jobsController.isCount.value < 1,
                  route: Routes.thirdStep,
                  isEnabled: true,
                ),
                _buildTaskItem(
                  icon: Icons.tune,
                  text: 'Set your job preferences.',
                  isCompleted: jobsController.isCount.value >= 2,
                  showArrow: jobsController.isCount.value < 2,
                  route: Routes.tenthStep,
                  isEnabled: jobsController.isCount.value >= 1,
                ),
                _buildTaskItem(
                  icon: Icons.account_balance_wallet,
                  text: 'Send Reviews for your customers.',
                  isCompleted: jobsController.isCount.value >= 3,
                  showArrow: jobsController.isCount.value < 3,
                  route: Routes.thirTheen,
                  isEnabled: jobsController.isCount.value >= 2,
                ),
                const SizedBox(height: 40),
                _buildInfoSection(),
                const SizedBox(height: 24),
                _buildBasicsSection(),
                const SizedBox(height: 32),
                _buildHelpSection(),
              ],
            ),
          )),
    );
  }

 Widget _buildTaskItem({
  required IconData icon,
  required String text,
  bool isCompleted = false,
  bool showArrow = false,
  String? route,
  bool isEnabled = true,
}) {
  return InkWell(
    onTap: (showArrow && route != null && isEnabled)
        ? () => Get.toNamed(route)
        : null,
    child: Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isCompleted ? Colors.green : (isEnabled ? Colors.blue : Colors.grey),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isEnabled ? Colors.black87 : Colors.grey,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                color: isEnabled ? Colors.blue : Colors.grey,
                size: 16,
              ),
          ],
        ),
      ),
    ),
  );
}

  // _buildInfoSection, _buildBasicsSection, _buildHelpSection, _buildHelpItem stay the same
}


  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.lightbulb_outline, color: Colors.black87),
            SizedBox(width: 8),
            Text(
              'How jobs work on Thumbtack',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Use this quick guide to understand how you get jobs on Thumbtack, as well as when and how you pay for new customers.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicsSection() {
    // Example list of basics, can be expanded in the future
    final List<Map<String, dynamic>> basics = [
      {
        'title': 'How to get leads',
        'color': Colors.pink.shade50,
        // 'image': ... // Add image asset or widget if needed
      },
      {
        'title': 'Payments',
        'color': const Color.fromARGB(255, 122, 6, 44),
        // 'image': ... // Add image asset or widget if needed
      },
      {
        'title': 'Service',
        'color': const Color.fromARGB(255, 20, 7, 108),
        // 'image': ... // Add image asset or widget if needed
      },
      {
        'title': 'Invoice',
        'color': const Color.fromARGB(255, 89, 5, 126),
        // 'image': ... // Add image asset or widget if needed
      },
      {
        'title': 'Yalpax',
        'color': const Color.fromARGB(255, 243, 255, 231),
        // 'image': ... // Add image asset or widget if needed
      },
      // Add more items here as needed
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The basics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: basics.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = basics[index];
              return SizedBox(
                width: 160,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: item['color'],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // You can add an image or icon here if needed
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Need more information?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _buildHelpItem(Icons.help_outline, 'More help articles'),
        _buildHelpItem(Icons.play_circle_outline, 'Video guides'),
      ],
    );
  }

  Widget _buildHelpItem(IconData icon, String text) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.blue,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
