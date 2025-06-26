import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/advanced_dropdown_field.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/core/widgets/custom_input.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

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
    // Debug: Log the selected state from first step
    print('Seventh Step - Selected State: ${controller.selectedState.value}');
    
    // If we have a selected state from first step, make sure it's in allStates
    if (controller.selectedState.value != null) {
      final selectedState = controller.selectedState.value!;
      final exists = controller.allStates.any((state) => state['id'] == selectedState['id']);
      
      if (!exists) {
        // Add the selected state to allStates if it's not already there
        controller.allStates.add(selectedState);
        print('Added selected state to allStates: ${selectedState['name']}');
      } else {
        print('Selected state already exists in allStates: ${selectedState['name']}');
      }
    }
    
    // If no states are loaded yet, fetch some default states
    if (controller.allStates.isEmpty) {
      await controller.fetchStates('');
      print('Fetched default states, count: ${controller.allStates.length}');
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
          onPressed: () => Get.back(),
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

                CustomInput(
                  focusNode: _focusNodes[0],
                  prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                  label: 'Year founded',
                  hint: 'e.g. 2000',
                  controller: controller.yearFoundedController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter founding year';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid year';
                    }
                    return null;
                  },
                
                ),
                const SizedBox(height: 16),
                CustomInput(
                  focusNode: _focusNodes[1],
                  prefixIcon: const Icon(Icons.people_outline, size: 20),
                  label: 'Number of employees',
                  controller: controller.numberOfEmployeesController,
                  hint: 'e.g. 1',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employee count';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
               
                ),
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
                  prefixIcon: const Icon(Icons.location_city_outlined, size: 20),
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
                    if (value != null && value.isNotEmpty && value.length != 5) {
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
                      Get.toNamed(Routes.eightStep);
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
    // Get the selected state from the controller
    final selectedState = controller.selectedState.value;
    
    // Find the state in allStates that matches the selected state
    final selected = selectedState != null 
        ? controller.allStates.firstWhere(
            (s) => s['id'] == selectedState['id'],
            orElse: () => selectedState, // Use the selected state if not found in allStates
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "State",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        AdvancedDropdownField<Map<String, dynamic>>(
          label: 'Select your state',
          hint: 'Search states...',
          items: controller.allStates,
          selectedValue: selected,
          getLabel: (item) => item['name'] ?? '',
          onChanged: (selectedItem) {
            controller.selectedState.value = selectedItem;
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
        ),
        if (selectedState != null) ...[
          const SizedBox(height: 4),
          Text(
            "Pre-selected from your service location",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}