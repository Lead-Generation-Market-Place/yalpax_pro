import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class ElevenStep extends GetView<AuthController> {
  const ElevenStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Job preferences',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.onBackground),
      ),
      body: Column(
        children: [
          // Enhanced progress bar
          LinearProgressIndicator(
            value: 0.85, // 11/13 steps (assuming 13-step process)
            minHeight: 4,
            backgroundColor: colors.surfaceVariant,
            color: colors.primary,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Text(
                    'Control where, when, and how you work',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your leads exactly match your availability, work areas, and other preferences.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Example lead button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: Icon(Icons.visibility_outlined, size: 18, color: colors.primary),
                      label: Text(
                        'See an example lead',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Get.toNamed(Routes.exampleScreen);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Preferences card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your job preferences',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildPreferenceItem(
                          icon: Icons.access_time,
                          text: 'Customers can book me for a job between 10am–2pm',
                          color: colors.primary,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildPreferenceItem(
                          icon: Icons.home_work,
                          text: 'I work on residential and commercial properties',
                          color: colors.primary,
                        ),
                        const SizedBox(height: 12),
                        
                        _buildPreferenceItem(
                          icon: Icons.build,
                          text: 'I work on any project size',
                          color: colors.primary,
                        ),
                      ],
                    ),
                  ),
                  
                  // Spacer to push content up when keyboard appears
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Bottom button with safe area
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 16,
              top: 8,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.toNamed(Routes.twelvthstep);
                },
                child: Text(
                  'Next',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreferenceItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(Get.context!).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}