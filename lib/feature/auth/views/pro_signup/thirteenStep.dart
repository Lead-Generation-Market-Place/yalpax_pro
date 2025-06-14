import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';

class Thirteenstep extends GetView<AuthController> {
  const Thirteenstep({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _introController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Introduce your business"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 1.0,
            backgroundColor: Colors.grey[200],
            color: Colors.blueAccent,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _introController,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: "Introduce your business.",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Minimum 40 characters",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "EXAMPLE INTRODUCTIONS",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              _exampleCard("My focus is quality. I never cut corners, even when it’s more expensive. Some of my competitors are cheaper, but I will take the time to make sure you’re 100% happy."),
              const SizedBox(height: 12),
              _exampleCard("I've been doing this for a really long time and I know how to get your home exactly what it needs. I’ll make sure to leave a note after each visit with references."),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.blueAccent, width: 2)),
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You can mention:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    BulletPoint(text: "Years in business"),
                    BulletPoint(text: "What you’re passionate about"),
                    BulletPoint(text: "Special skills or equipment"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Validate and go next
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("Next"),
          ),
        ),
      ),
    );
  }

  Widget _exampleCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Text(text),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("• ", style: TextStyle(fontSize: 18)),
        Expanded(child: Text(text)),
      ],
    );
  }
}
