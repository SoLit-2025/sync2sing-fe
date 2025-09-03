import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sync2sing/config/theme/app_colors.dart';
import 'package:sync2sing/features/home_hub/views/main_home_page.dart';
import 'package:sync2sing/features/my/views/my_page.dart';
import 'package:sync2sing/features/home_hub/views/solo_training_home_page.dart';
import 'package:sync2sing/features/home_hub/views/duet_training_home_page.dart';

class MainTabScreen extends StatelessWidget {
  final int initialTabIndex;

  const MainTabScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: AppColors.grayscale8,
        height: 60.h,
        border: Border(top: BorderSide(color: AppColors.grayscale6, width: 0.5)),
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: 'Solo'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.group), label: 'Duet'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person_crop_circle), label: 'My'),
        ],
        activeColor: AppColors.primaryRed,
        inactiveColor: AppColors.grayscale3,
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const MainHomePage();
          case 1:
            return const SoloTrainingHomePage();
          case 2:
            return const DuetTrainingHomePage();
          case 3:
            return const MyPage();
          default:
            return const Center(child: Text('Unknown'));
        }
      },
      controller: CupertinoTabController(initialIndex: initialTabIndex),
    );
  }
}
