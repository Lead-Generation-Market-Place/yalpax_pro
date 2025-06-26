import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class TwelvthStep extends GetView<AuthController> {
  const TwelvthStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Availability',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.onBackground),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set your availability',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Customers will only request jobs during the times you set. You\'ll need at least 12 hours of availability a week to show up in search results.',
              style: textTheme.bodyLarge?.copyWith(
                color: colors.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),

            // Availability Options
            _buildAvailabilityOptions(context),
            const SizedBox(height: 24),

            // Days Table
            _buildDaysTable(),
            const SizedBox(height: 24),

            // Lead Time Section
            // _buildLeadTimeSection(),
            const SizedBox(height: 24),

            // Team Capacity Section
            // _buildTeamCapacitySection(),
            const SizedBox(height: 24),

            // Travel Time Section
            // _buildTravelTimeSection(),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.toNamed(Routes.thirteenStep);
                },
                child: Text(
                  'Save business hours',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityOptions(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final controller = Get.find<AuthController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use business hours option
        Obx(() => RadioListTile<int>(
          value: 1,
          groupValue: controller.availabilityOption.value,
          onChanged: (value) {
            controller.availabilityOption.value = value!;
          },
          title: Text(
            'Use business hours',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sun    12:00 a.m. - midnight',
                style: textTheme.bodyMedium,
              ),
              Text(
                'Mon    12:00 a.m. - midnight',
                style: textTheme.bodyMedium,
              ),
              Text(
                'Tues    12:00 a.m. - midnight',
                style: textTheme.bodyMedium,
              ),
              Text(
                'Wed    12:00 a.m. - midnight',
                style: textTheme.bodyMedium,
              ),
              Text(
                'Thurs    12:00 a.m. - midnight',
                style: textTheme.bodyMedium,
              ),
              Text(
                'Fri    12:00 a.m. - midnight',
                style: textTheme.bodyMedium,
              ),
              Text(
                'Sat    12:00 a.m. - midnight',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Use any open day or time option
        Obx(() => RadioListTile<int>(
          value: 2,
          groupValue: controller.availabilityOption.value,
          onChanged: (value) {
            controller.availabilityOption.value = value!;
          },
          title: Text(
            'Use any open day or time',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Customers can request jobs during any time your calendar is not blocked.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        ),
      ],
    );
  }

  Widget _buildDaysTable() {
    final theme = Theme.of(Get.context!);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final controller = Get.find<AuthController>();

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit availability',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Days list with checkboxes and edit functionality
        ...List.generate(7, (index) {
          final day = controller.days[index];
          return Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: day['selected'] as bool,
                    onChanged: (value) {
                      controller.toggleDaySelection(index);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),),
                   SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      day['name'] as String,
                      style: textTheme.bodyLarge,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      day['time'] as String,
                      style: textTheme.bodyLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.toggleDayEdit(index);
                    },
                    child: Text(
                      'Edit',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Edit time dropdowns (shown when editing)
              if (day['editing'] as bool) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 68), // Align with checkbox
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: day['startTime'] as String,
                        items: _buildTimeDropdownItems(),
                        onChanged: (value) {
                          controller.updateDayTime(
                            index, 
                            startTime: value!, 
                            endTime: day['endTime'] as String
                          );
                        },
                        decoration: InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: day['endTime'] as String,
                        items: _buildTimeDropdownItems(),
                        onChanged: (value) {
                          controller.updateDayTime(
                            index, 
                            startTime: day['startTime'] as String, 
                            endTime: value!
                          );
                        },
                        decoration: InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
            ],
          );
        }),
        
        // Apply to selected days button
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              controller.applyToSelectedDays();
            },
            child: Text(
              'Apply to selected days',
              style: textTheme.bodyLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ));
  }

  List<DropdownMenuItem<String>> _buildTimeDropdownItems() {
    return [
      '12:00 AM', '1:00 AM', '2:00 AM', '3:00 AM', '4:00 AM', 
      '5:00 AM', '6:00 AM', '7:00 AM', '8:00 AM', '9:00 AM', 
      '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM', '2:00 PM', 
      '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM', 
      '8:00 PM', '9:00 PM', '10:00 PM', '11:00 PM', '12:00 AM (next day)'
    ].map((time) {
      return DropdownMenuItem<String>(
        value: time,
        child: Text(time),
      );
    }).toList();
  }

  // ... [Keep all other existing methods (_buildLeadTimeSection, _buildTeamCapacitySection, etc.)]
}