import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class ThirdStep extends GetView<AuthController>{
  const ThirdStep({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BusinessForm(),
      ),
    );
  }
}

class BusinessForm extends StatefulWidget {
  @override
  _BusinessFormState createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  String? _heardAboutUs;
  String? _businessSize;
  final _otherController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool get _isSubmitEnabled {
    if (_heardAboutUs == null || _businessSize == null) return false;
    if (_heardAboutUs == 'Other' && _otherController.text.isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: () => setState(() {}),
      child: ListView(
        children: [
          const Text(
            "You're in demand! There were 5,123 Cleaner jobs last month in your area.",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tell us more about your business',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'This information isn’t shared publicly. It helps us get to know our pros better and improve our services over time.',
          ),
          const SizedBox(height: 20),
          const Text(
            'How did you hear about us?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...[
            'Advertisement',
            'Online search',
            'Referral',
            'Social Media',
            'Other',
          ].map((option) => RadioListTile(
                title: Text(option),
                value: option,
                groupValue: _heardAboutUs,
                onChanged: (value) {
                  setState(() {
                    _heardAboutUs = value as String?;
                  });
                },
              )),
          if (_heardAboutUs == 'Other')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _otherController,
                decoration: const InputDecoration(labelText: 'Please specify (required)'),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'How big is your business?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...[
            '1 person (I\'m the owner/operator)',
            '2-3 people',
            '4-9 people',
            '10+',
          ].map((option) => RadioListTile(
                title: Text(option),
                value: option,
                groupValue: _businessSize,
                onChanged: (value) {
                  setState(() {
                    _businessSize = value as String?;
                  });
                },
              )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSubmitEnabled ? () {Get.toNamed(Routes.fourthStep);} : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.lightBlueAccent,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
