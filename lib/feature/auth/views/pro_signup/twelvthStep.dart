import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/main.dart';

import '../../../auth/services/auth_service.dart';

enum AvailabilityType { businessHours, anyTime }

class TwelvthStep extends StatefulWidget {
  @override
  _TwelvthStepState createState() => _TwelvthStepState();
}

class _TwelvthStepState extends State<TwelvthStep> {
  final AuthService _authService = Get.find<AuthService>();
  final authController = Get.put(AuthController());
  var isLoading = false;

  AvailabilityType selectedType = AvailabilityType.anyTime;
  bool isEditing = false;

  // Map to store selected state of each day
  Map<String, bool> selectedDays = {
    'Sun': true,
    'Mon': true,
    'Tues': true,
    'Wed': true,
    'Thurs': true,
    'Fri': true,
    'Sat': true,
  };

  // Map to store which days are being edited
  Map<String, bool> editingDays = {
    'Sun': false,
    'Mon': false,
    'Tues': false,
    'Wed': false,
    'Thurs': false,
    'Fri': false,
    'Sat': false,
  };

  // Map to store availability times
  Map<String, String> availability = {
    'Sun': '4 am - midnight',
    'Mon': '4 am - midnight',
    'Tues': '4 am - midnight',
    'Wed': '4 am - midnight',
    'Thurs': '4 am - midnight',
    'Fri': '4 am - midnight',
    'Sat': '4 am - midnight',
  };

  // Map to store temporary time selections
  Map<String, Map<String, String>> tempTimes = {
    'Sun': {'start': '4 am', 'end': 'midnight'},
    'Mon': {'start': '4 am', 'end': 'midnight'},
    'Tues': {'start': '4 am', 'end': 'midnight'},
    'Wed': {'start': '4 am', 'end': 'midnight'},
    'Thurs': {'start': '4 am', 'end': 'midnight'},
    'Fri': {'start': '4 am', 'end': 'midnight'},
    'Sat': {'start': '4 am', 'end': 'midnight'},
  };

  // Selected time range for applying to multiple days
  String selectedStartTime = '4 am';
  String selectedEndTime = 'midnight';

  // List of available time options
  final List<String> startTimeOptions = [
    '12 am',
    '1 am',
    '2 am',
    '3 am',
    '4 am',
    '5 am',
    '6 am',
    '7 am',
    '8 am',
    '9 am',
    '10 am',
    '11 am',
    '12 pm',
    '1 pm',
    '2 pm',
    '3 pm',
    '4 pm',
    '5 pm',
    '6 pm',
    '7 pm',
    '8 pm',
    '9 pm',
    '10 pm',
    '11 pm',
  ];

  final List<String> endTimeOptions = [
    '12 am',
    '1 am',
    '2 am',
    '3 am',
    '4 am',
    '5 am',
    '6 am',
    '7 am',
    '8 am',
    '9 am',
    '10 am',
    '11 am',
    '12 pm',
    '1 pm',
    '2 pm',
    '3 pm',
    '4 pm',
    '5 pm',
    '6 pm',
    '7 pm',
    '8 pm',
    '9 pm',
    '10 pm',
    '11 pm',
    'midnight',
  ];

  // Settings
  String leadTimeNotice = '1 day';
  String leadTimeAdvance = '24 months';
  String timeZone = 'Pacific Time Zone';
  String jobsPerSlot = '1 job';
  String travelTime = '30 minutes';

  void _toggleDayEditing(String day) {
    setState(() {
      // Close any other open day editors
      if (!editingDays[day]!) {
        editingDays.forEach((key, value) {
          editingDays[key] = false;
        });
      }
      editingDays[day] = !editingDays[day]!;

      // Initialize temp times with current values
      if (editingDays[day]!) {
        final times = availability[day]!.split(' - ');
        tempTimes[day] = {'start': times[0], 'end': times[1]};
      }
    });
  }

  void _updateDayTime(String day) {
    setState(() {
      availability[day] =
          '${tempTimes[day]!['start']} - ${tempTimes[day]!['end']}';
      editingDays[day] = false;
    });
  }

  void _applyToSelectedDays(String fromDay) {
    setState(() {
      selectedDays.forEach((day, isSelected) {
        if (isSelected && day != fromDay) {
          tempTimes[day] = Map.from(tempTimes[fromDay]!);
          availability[day] =
              '${tempTimes[fromDay]!['start']} - ${tempTimes[fromDay]!['end']}';
        }
      });
    });
  }

  Widget _buildDayRow(String day) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Checkbox(
                value: selectedDays[day],
                onChanged: (value) => _updateDaySelection(day, value),
              ),
              SizedBox(
                width: 80,
                child: Text(day, style: TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: Text(availability[day]!, style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () => _toggleDayEditing(day),
                child: Text(
                  editingDays[day]! ? 'Done' : 'Edit',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        if (editingDays[day]!)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 48.0, bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: tempTimes[day]!['start'],
                        decoration: InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                        ),
                        items: startTimeOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            tempTimes[day]!['start'] = value!;
                            availability[day] =
                                '${tempTimes[day]!['start']} - ${tempTimes[day]!['end']}';
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Text('to'),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: tempTimes[day]!['end'],
                        decoration: InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                        ),
                        items: endTimeOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            tempTimes[day]!['end'] = value!;
                            availability[day] =
                                '${tempTimes[day]!['start']} - ${tempTimes[day]!['end']}';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 48.0, bottom: 16.0),
                child: TextButton(
                  onPressed: () => _applyToSelectedDays(day),
                  child: Text(
                    'Apply to selected days',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _openEditAvailability(BuildContext context) {
    setState(() {
      isEditing = true;
    });
  }

  void _updateDaySelection(String day, bool? value) {
    setState(() {
      selectedDays[day] = value ?? false;
    });
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Done'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Lead Time Section
                  Text(
                    'Lead time',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Set a lead time that requires no more than a week\'s notice and allows customers to schedule you at least 2 weeks in advance.',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: leadTimeNotice,
                          decoration: InputDecoration(
                            labelText:
                                'How much notice do you need to do a job?',
                            border: OutlineInputBorder(),
                          ),
                          items: ['1 day', '2 days', '3 days'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              this.setState(() {
                                leadTimeNotice = value!;
                              });
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: leadTimeAdvance,
                          decoration: InputDecoration(
                            labelText:
                                'How far in advance can customers book you?',
                            border: OutlineInputBorder(),
                          ),
                          items: ['24 months', '18 months', '12 months'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              this.setState(() {
                                leadTimeAdvance = value!;
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Time Zone Section
                  SizedBox(height: 24),
                  Text(
                    'Time Zone',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: timeZone,
                    decoration: InputDecoration(
                      labelText: 'Select your time zone',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                          'Pacific Time Zone',
                          'Eastern Time Zone',
                          'Central Time Zone',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        this.setState(() {
                          timeZone = value!;
                        });
                      });
                    },
                  ),

                  // Team Capacity Section
                  SizedBox(height: 24),
                  Text(
                    'Team capacity',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Allow multiple jobs to be scheduled at the same time by setting the number of jobs your team can take per time slot.',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: jobsPerSlot,
                    decoration: InputDecoration(
                      labelText: 'Jobs per time slot',
                      border: OutlineInputBorder(),
                    ),
                    items: ['1 job', '2 jobs', '3 jobs'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        this.setState(() {
                          jobsPerSlot = value!;
                        });
                      });
                    },
                  ),

                  // Travel Time Section
                  SizedBox(height: 24),
                  Text(
                    'Travel time',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Set the time you need between jobs for travel.',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: travelTime,
                    decoration: InputDecoration(
                      labelText: 'How much time do you need between jobs?',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                          '15 minutes',
                          '30 minutes',
                          '45 minutes',
                          '1 hour',
                          '1.5 hours',
                          '2 hours',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        this.setState(() {
                          travelTime = value!;
                        });
                      });
                    },
                  ),

                  SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Add this method to prepare the schedule data
  Map<String, dynamic> _prepareScheduleData() {
    return {
      'Sun': {
        'selected': selectedDays['Sun'],
        'availability': availability['Sun'],
      },
      'Mon': {
        'selected': selectedDays['Mon'],
        'availability': availability['Mon'],
      },
      'Tues': {
        'selected': selectedDays['Tues'],
        'availability': availability['Tues'],
      },
      'Wed': {
        'selected': selectedDays['Wed'],
        'availability': availability['Wed'],
      },
      'Thurs': {
        'selected': selectedDays['Thurs'],
        'availability': availability['Thurs'],
      },
      'Fri': {
        'selected': selectedDays['Fri'],
        'availability': availability['Fri'],
      },
      'Sat': {
        'selected': selectedDays['Sat'],
        'availability': availability['Sat'],
      },
    };
  }

  // Add this method to save business hours
  Future<void> _saveBusinessHours() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Get the current user
      final user = supabase.auth.currentUser!.id;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get the provider ID for the current user
      final providerResponse = await Supabase.instance.client
          .from('service_providers')
          .select('provider_id')
          .eq('user_id', user)
          .single();

      if (providerResponse == null) {
        throw Exception('Provider not found');
      }

      final providerId = providerResponse['provider_id'];

      // Save business hours
      final result = await authController.saveBusinessHours(
        providerId: providerId,
        timezone: timeZone,
        availableAnyTime: selectedType == AvailabilityType.anyTime,
        schedule: _prepareScheduleData(),
      );

      if (result['status'] == 'success') {
        Fluttertoast.showToast(msg: result['message']);
        Get.offAllNamed(Routes.jobs);
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to save business hours: ${e.toString()}',
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Availability'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Existing body content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  'Set your availability',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Customers will only request jobs to be done during the times you set. You\'ll need at least 12 hours of availability a week to show up in search results.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedType = AvailabilityType.anyTime;
                      isEditing = false;
                    });
                    _showSettingsBottomSheet(context);
                  },
                  child: RadioListTile<AvailabilityType>(
                    title: Text('Use any open day or time'),
                    value: AvailabilityType.anyTime,
                    groupValue: selectedType,
                    onChanged: (AvailabilityType? value) {
                      setState(() {
                        selectedType = value!;
                        isEditing = false;
                      });
                      _showSettingsBottomSheet(context);
                    },
                  ),
                ),
                if (selectedType == AvailabilityType.anyTime)
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: Text(
                      'Customers can request jobs to be done during any time your calendar is not blocked.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                SizedBox(height: 24),
                RadioListTile<AvailabilityType>(
                  title: Text('Use specific hours'),
                  value: AvailabilityType.businessHours,
                  groupValue: selectedType,
                  onChanged: (AvailabilityType? value) {
                    setState(() {
                      selectedType = value!;
                      isEditing = true;
                    });
                  },
                ),
                if (selectedType == AvailabilityType.businessHours)
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: Text(
                      'Note: You\'ll still get messages from customers outside these times.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),

                if (selectedType == AvailabilityType.businessHours) ...[
                  SizedBox(height: 16),

                  // Show availability list with expandable time selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...availability.keys
                          .map((day) => _buildDayRow(day))
                          .toList(),
                    ],
                  ),

                  // Lead Time Section
                  SizedBox(height: 24),
                  Text(
                    'Lead time',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Set a lead time that requires no more than a week\'s notice and allows customers to schedule you at least 2 weeks in advance.',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: leadTimeNotice,
                          decoration: InputDecoration(
                            labelText:
                                'How much notice do you need to do a job?',
                            border: OutlineInputBorder(),
                          ),
                          items: ['1 day', '2 days', '3 days'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              leadTimeNotice = value!;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: leadTimeAdvance,
                          decoration: InputDecoration(
                            labelText:
                                'How far in advance can customers book you?',
                            border: OutlineInputBorder(),
                          ),
                          items: ['24 months', '18 months', '12 months'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              leadTimeAdvance = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Time Zone Section
                  SizedBox(height: 24),
                  Text(
                    'Time Zone',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: timeZone,
                    decoration: InputDecoration(
                      labelText: 'Select your time zone',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                          'Pacific Time Zone',
                          'Eastern Time Zone',
                          'Central Time Zone',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        timeZone = value!;
                      });
                    },
                  ),

                  // Team Capacity Section
                  SizedBox(height: 24),
                  Text(
                    'Team capacity',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Allow multiple jobs to be scheduled at the same time by setting the number of jobs your team can take per time slot.',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: jobsPerSlot,
                    decoration: InputDecoration(
                      labelText: 'Jobs per time slot',
                      border: OutlineInputBorder(),
                    ),
                    items: ['1 job', '2 jobs', '3 jobs'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        jobsPerSlot = value!;
                      });
                    },
                  ),

                  // Travel Time Section
                  SizedBox(height: 24),
                  Text(
                    'Travel time',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Set the time you need between jobs for travel.',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: travelTime,
                    decoration: InputDecoration(
                      labelText: 'How much time do you need between jobs?',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                          '15 minutes',
                          '30 minutes',
                          '45 minutes',
                          '1 hour',
                          '1.5 hours',
                          '2 hours',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        this.setState(() {
                          travelTime = value!;
                        });
                      });
                    },
                  ),
                ],

                SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: isLoading ? null : _saveBusinessHours,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save business hours',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),

    
        
        ],
      ),
    );
  }
}

// Edit Availability Bottom Sheet
class EditAvailabilityBottomSheet extends StatefulWidget {
  final Map<String, String> availability;
  final Function(Map<String, String>) onSave;

  const EditAvailabilityBottomSheet({
    Key? key,
    required this.availability,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditAvailabilityBottomSheetState createState() =>
      _EditAvailabilityBottomSheetState();
}

class _EditAvailabilityBottomSheetState
    extends State<EditAvailabilityBottomSheet> {
  late Map<String, String> editedAvailability;

  // List of available time options
  final List<String> startTimeOptions = [
    '12 am',
    '1 am',
    '2 am',
    '3 am',
    '4 am',
    '5 am',
    '6 am',
    '7 am',
    '8 am',
    '9 am',
    '10 am',
    '11 am',
    '12 pm',
    '1 pm',
    '2 pm',
    '3 pm',
    '4 pm',
    '5 pm',
    '6 pm',
    '7 pm',
    '8 pm',
    '9 pm',
    '10 pm',
    '11 pm',
  ];

  final List<String> endTimeOptions = [
    '12 am',
    '1 am',
    '2 am',
    '3 am',
    '4 am',
    '5 am',
    '6 am',
    '7 am',
    '8 am',
    '9 am',
    '10 am',
    '11 am',
    '12 pm',
    '1 pm',
    '2 pm',
    '3 pm',
    '4 pm',
    '5 pm',
    '6 pm',
    '7 pm',
    '8 pm',
    '9 pm',
    '10 pm',
    '11 pm',
    'midnight',
  ];

  @override
  void initState() {
    editedAvailability = Map.from(widget.availability);
    super.initState();
  }

  void _updateTime(String day, String newTime) {
    setState(() {
      editedAvailability[day] = newTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Edit availability',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Select available days and set hours.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),

          ...editedAvailability.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              subtitle: Text(entry.value),
              trailing: Icon(Icons.edit),
              onTap: () {
                _showTimeDialog(context, entry.key);
              },
            );
          }).toList(),

          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onSave(editedAvailability);
              Navigator.pop(context);
            },
            child: Text('Save business hours'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimeDialog(BuildContext context, String day) {
    String tempStartTime = editedAvailability[day]!.split(" - ")[0];
    String tempEndTime = editedAvailability[day]!.split(" - ")[1];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set time for $day',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Done'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: tempStartTime,
                          decoration: InputDecoration(
                            labelText: 'Start Time',
                            border: OutlineInputBorder(),
                          ),
                          items: startTimeOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              tempStartTime = value!;
                              this.setState(() {
                                editedAvailability[day] =
                                    '$tempStartTime - $tempEndTime';
                              });
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('to'),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: tempEndTime,
                          decoration: InputDecoration(
                            labelText: 'End Time',
                            border: OutlineInputBorder(),
                          ),
                          items: endTimeOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              tempEndTime = value!;
                              this.setState(() {
                                editedAvailability[day] =
                                    '$tempStartTime - $tempEndTime';
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
