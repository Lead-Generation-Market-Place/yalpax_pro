import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/feature/auth/services/auth_service.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';
import 'package:yalpax_pro/feature/jobs/widgets/horizontal_services_list.dart';

class JobsView extends StatefulWidget {
  const JobsView({super.key});

  @override
  State<JobsView> createState() => _JobsViewState();
}

class _JobsViewState extends State<JobsView> {
  final TextEditingController _searchController = TextEditingController();
  final AuthController authController = Get.put(AuthController());
  final AuthService authService = Get.put(AuthService());
  final jobsController controller = Get.put(jobsController());

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initializeState();
    super.initState();
  }

  Future<void> initializeState() async {
    try {
      await controller.checkAuthAndNavigate();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              authService.isAuthenticated.value = false;
              await authController.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(hintText: 'Search jobs...'),
        ),
      ),
      bottomNavigationBar: BottomNavbar(),
    );
  }
}
