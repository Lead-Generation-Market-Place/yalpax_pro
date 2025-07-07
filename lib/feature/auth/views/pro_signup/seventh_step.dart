import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/advanced_dropdown_field.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeventhStep extends StatefulWidget {
  const SeventhStep({super.key});

  @override
  State<SeventhStep> createState() => _SeventhStepState();
}

class _SeventhStepState extends State<SeventhStep> {
  final controller = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();

    // Set focus to the first field after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      }

      // Load states and ensure selected state from first step is available
      _initializeStateData();
    });
  }

  Future<void> _initializeStateData() async {
  try {
    // First ensure states are loaded
    if (controller.allStates.isEmpty) {
      await controller.fetchStates('');
    }
    
    // Check if we have a selected state in the controller first
    if (controller.selectedState.value != null) {
      return; // Already have a selected state
    }
    
    // Fall back to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final selectedStateId = prefs.getString('selected_state_id');
    
    if (selectedStateId != null && controller.allStates.isNotEmpty) {
      final match = controller.allStates.firstWhereOrNull(
        (state) => state['id'].toString() == selectedStateId,
      );
      
      if (match != null) {
        controller.selectedState.value = match;
      }
    }
  } catch (e) {
    print('Error initializing state data: $e');
  }
}

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Business Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.close(1),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 0.8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      body: Obx(() {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Confirm some info for your business",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Fairfax",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50]?.withOpacity(0.3),
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.5),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.deepPurple[400],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "We filled in some info for you",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Make sure it's correct before you continue.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          // Handle "Not your business?" action
                        },
                        child: Text(
                          "Not your business?",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Business Details Section
                _buildSectionTitle("Business Details"),
                const SizedBox(height: 16),

                // Business Type Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Business Type',
                    prefixIcon: const Icon(Icons.business, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  value: controller.businessType.value,
                  hint: const Text('Select business type'),
                  items: controller.businessTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type[0].toUpperCase() + type.substring(1)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.businessType.value = newValue;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a business type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomInput(
                  focusNode: _focusNodes[0],
                  prefixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                  ),
                  label: 'Year founded',
                  hint: 'e.g. 2000',
                  controller: controller.yearFoundedController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter founding year';
                    }
                    final year = int.tryParse(value);
                    if (year == null) {
                      return 'Please enter a valid year';
                    }
                    final currentYear = DateTime.now().year;
                    if (year < 1900 || year > currentYear) {
                      return 'Please enter a year between 1800 and $currentYear';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (controller.businessType.value == 'company')
                CustomInput(
                  focusNode: _focusNodes[1],
                  prefixIcon: const Icon(Icons.people_outline, size: 20),
                  label: 'Number of employees',
                  controller: controller.numberOfEmployeesController,
                  hint: 'e.g. 1',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (controller.businessType.value == 'company') {
                      if (value == null || value.isEmpty) {
                        return 'Please enter employee count';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
                if (controller.businessType.value == 'company')
                const SizedBox(height: 28),
                const SizedBox(height: 28),

                // Location Section
                _buildSectionTitle("Main business location (optional)"),
                const SizedBox(height: 16),
                CustomInput(
                  focusNode: _focusNodes[2],
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                  label: 'Street name',
                  hint: 'Enter street name',
                  controller: controller.streetNameController,
                ),
                const SizedBox(height: 16),
                CustomInput(
                  focusNode: _focusNodes[3],
                  prefixIcon: const Icon(Icons.meeting_room_outlined, size: 20),
                  label: 'Suite or unit',
                  hint: 'Enter suite or unit',
                  controller: controller.suiteOrUniteController,
                ),
                const SizedBox(height: 16),
                CustomInput(
                  prefixIcon: const Icon(
                    Icons.location_city_outlined,
                    size: 20,
                  ),
                  label: 'City',
                  hint: 'Fairfax',
                  controller: controller.cityController,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                _buildStateDropdown(),
                const SizedBox(height: 16),
                CustomInput(
                  focusNode: _focusNodes[5],
                  prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                  label: 'Zip code',
                  hint: 'Enter zip code',
                  keyboardType: TextInputType.number,
                  controller: controller.zipCodeController,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value.length != 5) {
                      return 'Zip code must be 5 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Disclaimer Text
                Text(
                  "By tapping Next, you confirm the above info is correct, you're this business's authorized representative and you understand you're solely responsible for your profile's contents.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Next Button
                CustomButton(
                  isLoading: controller.isLoading.value,
                  text: 'Next',
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Get.toNamed(Routes.ninthStep);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.grey[800],
      ),
    );
  }

   Widget _buildStateDropdown() {
    return AdvancedDropdownField<Map<String, dynamic>>(
      label: 'Select your state',
      hint: 'Search states...',
      items: controller.allStates,
      selectedValue: controller.selectedState.value,
      getLabel: (item) => item['name'] ?? '',
      onChanged: (selectedItem) async {
        controller.selectedState.value = selectedItem;
        if (selectedItem != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_state_id', selectedItem['id'].toString());
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a state';
        }
        return null;
      },
      isRequired: true,
      enableSearch: true,
      onSearchChanged: (query) {
        controller.fetchStates(query);
      },
    );
  }

}
