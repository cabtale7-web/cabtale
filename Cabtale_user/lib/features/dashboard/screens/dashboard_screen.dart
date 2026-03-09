import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/dashboard/domain/models/navigation_model.dart';
import 'package:ride_sharing_user_app/features/home/screens/home_screen.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final PageStorageBucket bucket = PageStorageBucket();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<NavigationModel> item = [
      NavigationModel(
        name: 'home'.tr,
        activeIcon: Images.homingActive,
        inactiveIcon: Images.homingOutlaned,
        screen: const HomeScreen(),
      ),
      NavigationModel(
        name: 'activity'.tr,
        activeIcon: Images.activityActived,
        inactiveIcon: Images.activityOutlaned,
        screen: const TripScreen(fromProfile: false),
      ),
      NavigationModel(
        name: 'notification'.tr,
        activeIcon: Images.notificationStatusActived,
        inactiveIcon: Images.notificationStatusOutlined,
        screen: const NotificationScreen(),
      ),
      NavigationModel(
        name: 'profile'.tr,
        activeIcon: Images.profileActiveIcon,
        inactiveIcon: Images.profileOutlineIcon,
        screen: const ProfileScreen(),
      ),
    ];


    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, val) async {
        if (Get.find<BottomMenuController>().currentTab != 0) {
          Get.find<BottomMenuController>().setTabIndex(0);
          return;
        } else {
          Get.find<BottomMenuController>().exitApp();
        }
        return;
      },

      child: GetBuilder<BottomMenuController>(builder: (menuController) {

        return Scaffold(


          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              PageStorage(bucket: bucket, child: item[menuController.currentTab].screen),

              Positioned(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                    child: Container(

                      height: 67,
                      // REMOVE the 'color' property here
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        // ADD the gradient decoration here
                        // gradient: LinearGradient(
                        //   // Use theme colors for the gradient effect
                        //   colors: [
                        //     Theme.of(context).primaryColor,
                        //     Theme.of(context).primaryColor,
                        //
                        //
                        //      // Lighter shade (or your lightPrimary)
                        //              // Main color (or your lightSecondary)
                        //   ],
                        //   begin: Alignment.bottomRight,
                        //   end: Alignment.topLeft,
                        // ),

                        color: Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.3),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: generateBottomNavigationItems(menuController, item),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
  
  List<Widget> generateBottomNavigationItems(BottomMenuController menuController, List<NavigationModel> item) {

    List<Widget> items = [];
    for(int index = 0; index < item.length; index++) {
      items.add(Expanded(child: CustomMenuItem(
        isSelected: menuController.currentTab == index, 
        name: item[index].name,
        activeIcon: item[index].activeIcon,
        inActiveIcon: item[index].inactiveIcon,
        onTap: () => menuController.setTabIndex(index),
      )));
    }
    return items;
  }

}

class CustomMenuItem extends StatelessWidget {
  final bool isSelected;
  final String name;
  final String activeIcon;
  final String inActiveIcon;
  final VoidCallback onTap;

  const CustomMenuItem({
    super.key, required this.isSelected, required this.name, required this.activeIcon,
    required this.inActiveIcon, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,

      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(8),
        child: SizedBox(width: isSelected ? 90 : 50, child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [

            Image.asset(isSelected ? activeIcon : inActiveIcon, width: Dimensions.menuIconSize, height: Dimensions.menuIconSize,),

            isSelected ? Text(name.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: textRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall)) : const SizedBox(),
          ],
        )),
      ),
    );
  }

}