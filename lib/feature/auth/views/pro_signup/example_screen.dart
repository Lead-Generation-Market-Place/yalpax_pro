import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class ExampleScreen extends GetView<AuthController> {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Here\'s an example lead',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Each lead you get exactly matches your preferences. You\'ll get the customer\'s phone number after you send your first reply.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lead Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'AJ',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Andrew J.',
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '1 minute ago',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colors.onSurface.withOpacity(
                                          0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Exact match',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colors.onTertiaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),

                          // Job Details
                          Text(
                            'House cleaning',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildDetailRow(
                            icon: Icons.location_on_outlined,
                            text: 'Graham, WA 98338',
                            color: colors.primary,
                          ),
                          const SizedBox(height: 8),

                          _buildDetailRow(
                            icon: Icons.calendar_today_outlined,
                            text: 'Monday mornings',
                            color: colors.primary,
                          ),
                          const SizedBox(height: 8),

                          _buildDetailRow(
                            icon: Icons.phone_outlined,
                            text: 'xxx-xxx-9875',
                            color: colors.primary,
                          ),
                          const SizedBox(height: 16),

                          // Requirements List
                          Text(
                            'Requirements:',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          _buildCheckItem('1 bedroom'),
                          _buildCheckItem('Bathrooms: 2 bathrooms'),
                          _buildCheckItem('Frequency: Recurring'),
                          _buildCheckItem('Property type: Residential'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    'Got it',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(text, style: Theme.of(Get.context!).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildCheckItem(String text) {
    final colors = Theme.of(Get.context!).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outlined, size: 20, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(Get.context!).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
