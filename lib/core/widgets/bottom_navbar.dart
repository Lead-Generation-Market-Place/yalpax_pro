import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import '../constants/app_colors.dart';

class BottomNavController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxDouble indicatorPosition = 0.0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
    // Animate the indicator position
    indicatorPosition.value = index * 1.0;
    switch (index) {
      case 0:
        Get.toNamed(Routes.jobs);
        break;
      case 1:
        Get.toNamed(Routes.messages);
        break;
      case 2:
        Get.toNamed(Routes.services);
        break;
      case 3:
        Get.toNamed(Routes.notification);
        break;
      case 4:
        Get.toNamed(Routes.profile);
        break;
    }
  }
}

class BottomNavbar extends StatelessWidget {
  BottomNavbar({Key? key}) : super(key: key);

  final BottomNavController controller = Get.put(BottomNavController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final itemWidth = width / 5;

    return Container(
      
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: AppColors.neutral400,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.5,
            ),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _AnimatedNavIcon(
                  selected: controller.selectedIndex.value == 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_filled,
                ),
                label: 'Jobs',
              ),
              BottomNavigationBarItem(
                icon: _AnimatedNavIcon(
                  selected: controller.selectedIndex.value == 1,
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                ),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: _AnimatedNavIcon(
                  selected: controller.selectedIndex.value == 2,
                  icon: Icons.work_outline,
                  activeIcon: Icons.work,
                ),
                label: 'Services',
              ),
              BottomNavigationBarItem(
                icon: _AnimatedNavIcon(
                  selected: controller.selectedIndex.value == 3,
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                ),
                label: 'Alerts',
              ),
              BottomNavigationBarItem(
                icon: _AnimatedNavIcon(
                  selected: controller.selectedIndex.value == 4,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                ),
                label: 'Profile',
              ),
            ],
          ),
          
          // Animated indicator
          Obx(() => AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            bottom: 0,
            left: controller.indicatorPosition.value * itemWidth + itemWidth * 0.2,
            child: Container(
              width: itemWidth * 0.6,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final IconData activeIcon;

  const _AnimatedNavIcon({
    required this.selected,
    required this.icon,
    required this.activeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(selected ? 1.2 : 1.0),
          child: Icon(
            selected ? activeIcon : icon,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}