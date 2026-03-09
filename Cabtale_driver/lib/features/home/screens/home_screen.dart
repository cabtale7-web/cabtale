import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_bottom_sheet_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_referral_view_widget.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/home_screen_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/home/widgets/add_vehicle_design_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/custom_menu/custom_menu_button_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/custom_menu/custom_menu_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/my_activity_list_view_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/ongoing_parcel_list_view_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/ongoing_ride_card_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/profile_info_card_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/vehicle_pending_widget.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_menu_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/sliver_delegate.dart';
import 'package:ride_sharing_user_app/common_widgets/zoom_drawer_context_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';


class HomeMenu extends GetView<ProfileController> {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (_) => ZoomDrawer(
        controller: _.zoomDrawerController,
        menuScreen: const ProfileMenuScreen(),
        mainScreen: const HomeScreen(),
        borderRadius: 24.0,
        isRtl: !Get.find<LocalizationController>().isLtr,
        angle: -5.0,
        menuBackgroundColor: Theme.of(context).primaryColor,
        slideWidth: MediaQuery.of(context).size.width * 0.85,
        mainScreenScale: .4,
        mainScreenTapClose: true,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool clickedMenu = false;
  @override
  void initState() {
    loadData();
    super.initState();
  }
  Future<void> loadData() async{
    Get.find<ProfileController>().getCategoryList(1);
    Get.find<ProfileController>().getDailyLog();
    Get.find<RideController>().getOngoingParcelList();
    Get.find<ProfileController>().getProfileLevelInfo();
    await Get.find<RideController>().getLastTrip();
    if(Get.find<RideController>().ongoingTripDetails != null){
      HomeScreenHelper().pendingLastRidePusherImplementation();
    }

    await Get.find<RideController>().getPendingRideRequestList(1,limit: 100);
    if(Get.find<RideController>().getPendingRideRequestModel != null){
      HomeScreenHelper().pendingParcelListPusherImplementation();
    }
    if(
    Get.find<ProfileController>().profileInfo?.vehicle == null &&
        Get.find<ProfileController>().profileInfo?.vehicleStatus == 0 &&
        Get.find<ProfileController>().isFirstTimeShowBottomSheet){
      Get.find<ProfileController>().updateFirstTimeShowBottomSheet(false);
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: Get.context!,
        isDismissible: false,
        builder: (_) => const HomeBottomSheetWidget(),
      );
    }

    HomeScreenHelper().checkMaintanenceMode();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async{
        Get.find<ProfileController>().getProfileInfo();
      },
      child: Scaffold(
          body: Stack(children: [
            CustomScrollView(slivers: [
              SliverPersistentHeader(pinned: true, delegate: SliverDelegate(
                  height: GetPlatform.isIOS ? 150 : 120,
                  child: Column(children: [
                    AppBarWidget(
                      title: 'dashboard'.tr, showBackButton: false,
                      onTap: (){
                        Get.find<ProfileController>().toggleDrawer();
                      },
                    ),
                  ])
              )),

              SliverToBoxAdapter(child: GetBuilder<ProfileController>(builder: (profileController) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 80.0),

                  if(profileController.profileInfo?.vehicle != null &&
                      profileController.profileInfo?.vehicleStatus != 0  &&
                      profileController.profileInfo?.vehicleStatus != 1
                  )
                    if(Get.find<ProfileController>().profileInfo?.vehicle != null)
                    const MyActivityListViewWidget(),
                    const SizedBox(height: 27),


                  if(profileController.profileInfo?.vehicle == null && profileController.profileInfo?.vehicleStatus == 0)
                    const AddYourVehicleWidget(),

                  if(profileController.profileInfo?.vehicle != null && profileController.profileInfo?.vehicleStatus == 1)
                    VehiclePendingWidget(
                      icon: Images.reward1,
                      description: 'create_account_approve_description_vehicle'.tr,
                      title: 'registration_not_approve_yet_vehicle'.tr,
                    ),

                 
                    GetBuilder<RideController>(builder: (rideController) {
                      return const OngoingRideCardWidget();
                    }),

                  if(Get.find<SplashController>().config?.referralEarningStatus ?? false)
                    const HomeReferralViewWidget(),

                  const SizedBox(height: 100),
                ]);
              }))
            ]),

            Positioned(top: GetPlatform.isIOS ? 120 : 110,
              left: 0,
              right: 0,
              child: GetBuilder<ProfileController>(builder: (profileController) {
                return GestureDetector(
                    onTap: (){
                      Get.to(()=> const ProfileScreen());
                    },
                    child: ProfileStatusCardWidget(profileController: profileController));
              }),
            ),
          ]),

          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
floatingActionButton: GetBuilder<RideController>(
  builder: (rideController) {
    final hasTrips = rideController.ongoingTrip != null && rideController.ongoingTrip!.isNotEmpty;

    final bool rideActive = hasTrips && (
      rideController.ongoingTrip![0].currentStatus == 'ongoing' ||
      rideController.ongoingTrip![0].currentStatus == 'accepted' ||
      (
        rideController.ongoingTrip![0].currentStatus == 'completed' &&
        rideController.ongoingTrip![0].paymentStatus == 'unpaid'
      ) ||
      (
        rideController.ongoingTrip![0].paidFare != "0" &&
        rideController.ongoingTrip![0].paymentStatus == 'unpaid'
      )
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 90),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔹 Map View Button
          InkWell(
            onTap: () {
              Get.to(() => const MapScreen());
            },
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 180,  
              height: 48, 
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Images.map,
                      height: 24, // ⬅️ bigger icon
                      width: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Map View',
                      style: textRegular.copyWith(
                        color: Colors.white,
                        fontSize: 16, // ⬅️ bigger text
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 24),

          // 🔹 Ongoing Ride Button
          InkWell(
            onTap: () {
              if (rideActive) {
                Get.find<RideController>().getCurrentRideStatus(froDetails: true);
              } else {
                showCustomSnackBar('no_trip_available'.tr);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 180,  // ⬅️ wider
              height: 48,  // ⬅️ taller
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Images.ongoing,
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ongoing Ride',
                      style: textRegular.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
),

      ),
    );
  }

}





