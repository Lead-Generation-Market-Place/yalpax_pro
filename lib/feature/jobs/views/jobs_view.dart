import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/bottom_navbar.dart';
import 'package:yalpax_pro/feature/jobs/controllers/jobs_controller.dart';
import 'package:yalpax_pro/feature/jobs/widgets/horizontal_services_list.dart';

class JobsView extends GetView<jobsController> {
  JobsView({super.key});
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
  
    
    );
  }
}
