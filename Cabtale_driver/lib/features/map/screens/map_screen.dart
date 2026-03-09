import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/widgets/custom_icon_card_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/driver_header_info_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/expendale_bottom_sheet_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/screens/ride_request_list_screen.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:vibration/vibration.dart';



class MapScreen extends StatefulWidget {
  final String fromScreen;
  const MapScreen({super.key,  this.fromScreen = 'home'});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver{
  GoogleMapController? _mapController;
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey<ExpandableBottomSheetState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _findingCurrentRoute();

    if (Get.find<RideController>().currentRideStatus == 'ongoing') {
      _startSpeedStream();
    }
  }

  StreamSubscription<Position>? _positionStream;
  double _speed = 0;
  bool _isSpeeding = false;

  void _startSpeedStream() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      double currentSpeed = (position.speed ?? 0) * 3.6;

      if (mounted) {
        setState(() {
          _speed = currentSpeed.roundToDouble();
        });

        if (_speed > 70 && !_isSpeeding) {
          setState(() {
            _isSpeeding = true;
          });
          _showSpeedWarning();
        } else if (_speed <= 70 && _isSpeeding) {
          setState(() {
            _isSpeeding = false;
          });
        }

      }
    }, onError: (e) {
      print("GPS Stream error: $e");
      if (mounted) {
        setState(() {
          _speed = 0;
        });
      }
    });
  }

  // void _showSpeedWarning() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Speeding Warning'),
  //         content: const Text('You are driving faster than 10 km/h! Please slow down.'),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showSpeedWarning() async {
    if (await Vibration.hasVibrator() ?? false) {
      if (await Vibration.hasAmplitudeControl() ?? false) {
        Vibration.vibrate(pattern: [0, 300, 200, 300], amplitude: 128);
      } else {
        Vibration.vibrate();
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Speeding Warning'),
          content: const Text('You are driving faster than 70 km/h! Please slow down.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }



  _findingCurrentRoute(){
    Get.find<RideController>().updateRoute(false, notify: false);
    Get.find<RiderMapController>().setSheetHeight(Get.find<RiderMapController>().currentRideState == RideState.initial ? 300 : 270, false);
    Get.find<RideController>().getPendingRideRequestList(1);
    if(Get.find<RideController>().ongoingTrip != null
        && Get.find<RideController>().ongoingTrip!.isNotEmpty
        && (Get.find<RideController>().ongoingTrip![0].currentStatus == 'ongoing'
            || Get.find<RideController>().ongoingTrip![0].currentStatus == 'accepted'
            || (Get.find<RideController>().ongoingTrip![0].currentStatus =='completed'
                && Get.find<RideController>().ongoingTrip![0].paymentStatus == 'unpaid'))  ){
      Get.find<RideController>().getCurrentRideStatus(froDetails: true, isUpdate: false);
      Get.find<RiderMapController>().setMarkersInitialPosition();
    }
    getCurrentLocation();
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.resumed){
      Get.find<RideController>().getCurrentRideStatus(froDetails: true, isUpdate: false,fromMapScreen: true);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }
    _positionStream?.cancel();
    super.dispose();
  }

  StreamSubscription? _locationSubscription;
  Marker? marker;
  GoogleMapController? _controller;

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load(Images.carTop);
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(Position? newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData!.latitude, newLocalData.longitude);
    setState(() {
      marker = Marker(
          markerId: const MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await Geolocator.getCurrentPosition();
      updateMarkerAndCircle(location, imageData);
      if (_locationSubscription != null) {
        _locationSubscription!.cancel();
      }

      _locationSubscription = Geolocator.getPositionStream().listen((newLocalData) {
        if (_controller != null) {
          _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0,
              zoom: 16)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (val){
        if(Navigator.canPop(context)){
          Get.find<RideController>().getOngoingParcelList();
          Get.find<RideController>().getLastTrip();
          Get.find<RideController>().updateRoute(true,notify: true);
          return;

        }else{
          Get.offAll(()=> const DashboardScreen());
        }

      },
      child: Scaffold(resizeToAvoidBottomInset: false,
        body: GetBuilder<RiderMapController>(builder: (riderMapController) {
          return GetBuilder<RideController>(builder: (rideController) {
            return ExpandableBottomSheet(key: key,persistentContentHeight: riderMapController.sheetHeight,
              background: GetBuilder<RideController>(builder: (rideController) {
                return Stack(children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: riderMapController.sheetHeight -
                          (Get.find<RiderMapController>().currentRideState == RideState.initial ? 80 : 20),
                    ),
                    child: GoogleMap(
                      style: Get.isDarkMode ? Get.find<ThemeController>().darkMap :
                      Get.find<ThemeController>().lightMap,
                      initialCameraPosition:  CameraPosition(
                        target:  (rideController.tripDetail != null &&
                            rideController.tripDetail!.pickupCoordinates != null) ?
                        LatLng(
                          rideController.tripDetail!.pickupCoordinates!.coordinates![1],
                          rideController.tripDetail!.pickupCoordinates!.coordinates![0],
                        ) : Get.find<LocationController>().initialPosition,
                        zoom: 16,
                      ),
                      onMapCreated: (GoogleMapController controller) async {
                        riderMapController.mapController = controller;
                        if(riderMapController.currentRideState.name != 'initial'){
                          if(riderMapController.currentRideState.name == 'accepted' || riderMapController.currentRideState.name == 'ongoing'){
                            Get.find<RideController>().remainingDistance(Get.find<RideController>().tripDetail!.id!,mapBound: true);
                          }else{
                            riderMapController.getPickupToDestinationPolyline();}
                        }
                        _mapController = controller;
                      },
                      onCameraMove: (CameraPosition cameraPosition) {
                      },
                      onCameraIdle: () {

                      },
                      minMaxZoomPreference: const MinMaxZoomPreference(0, AppConstants.mapZoom),
                      markers: Set<Marker>.of(riderMapController.markers),
                      polylines: riderMapController.polylines,
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                      trafficEnabled: riderMapController.isTrafficEnable,
                      indoorViewEnabled: true,
                      mapToolbarEnabled: true,
                    ),
                  ),

                  InkWell(
                    onTap: () => Get.to(const ProfileScreen()),
                    child: const DriverHeaderInfoWidget(),
                  ),

                  Positioned(bottom: Get.width * 0.95,right: 0, child: Align(
                    alignment: Alignment.bottomRight,
                    child: GetBuilder<LocationController>(builder: (locationController) {
                      return CustomIconCardWidget(
                        title: '', index: 5,
                        icon: riderMapController.isTrafficEnable ?
                        Images.trafficOnlineIcon : Images.trafficOfflineIcon,
                        iconColor: riderMapController.isTrafficEnable ?
                        Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).hintColor,
                        onTap: () => riderMapController.toggleTrafficView(),
                      );
                    }),
                  )),

                  GetBuilder<RideController>(
                    builder: (rideController) {
                      if (rideController.currentRideStatus == 'ongoing') {
                        return Positioned(
                          bottom: Get.width * 0.74,
                          right: 11,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 5),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Align(
                                    alignment: const Alignment(0.0, -0.65),
                                    child: AnimatedRadialGauge(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeOut,
                                      radius: 22,
                                      value: _speed,
                                      axis: const GaugeAxis(
                                        min: 0,
                                        max: 180,
                                        degrees: 180,
                                        style: GaugeAxisStyle(
                                          thickness: 2,
                                          background: Colors.white,
                                          segmentSpacing: 6,
                                        ),
                                        pointer: GaugePointer.needle(
                                          width: 0,
                                          height: 0,
                                          color: Colors.redAccent,
                                          borderRadius: 8,
                                        ),
                                        progressBar: GaugeProgressBar.rounded(
                                          color: Colors.redAccent,
                                        ),
                                        segments: [
                                          GaugeSegment(
                                            from: 0,
                                            to: 60,
                                            color: Colors.green,
                                            cornerRadius: Radius.zero,
                                          ),
                                          GaugeSegment(
                                            from: 60,
                                            to: 120,
                                            color: Colors.orange,
                                            cornerRadius: Radius.zero,
                                          ),
                                          GaugeSegment(
                                            from: 120,
                                            to: 180,
                                            color: Colors.red,
                                            cornerRadius: Radius.zero,
                                          ),
                                        ],
                                      ),
                                      builder: (context, child, value) => Center(
                                        child: Text(
                                          '${value.toStringAsFixed(0)} km/h',
                                          style: const TextStyle(
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink(); // Hide when not ongoing
                      }
                    },
                  ),

                  Positioned(bottom: Get.width * 0.81,right: 0, child: Align(
                    alignment: Alignment.bottomRight,
                    child: GetBuilder<LocationController>(builder: (locationController) {
                      return CustomIconCardWidget(
                        iconColor: Theme.of(context).primaryColor,
                        title: '', index: 5,icon: Images.currentLocation,
                        onTap: () async {
                          await locationController.getCurrentLocation(mapController: _mapController,isAnimate: false);
                        },
                      );
                    }),
                  )),

                  Positioned(child: Align(alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: (){
                        Get.find<RideController>().updateRoute(true,notify: true);
                        Get.off(()=> const DashboardScreen());
                      },
                      onHorizontalDragEnd: (DragEndDetails details){
                        _onHorizontalDrag(details);
                        Get.find<RideController>().updateRoute(true, notify: true);
                        Get.off(()=> const DashboardScreen());
                      },

                      child: Stack(children: [
                        SizedBox(width: Dimensions.iconSizeExtraLarge, child: Image.asset(
                          Images.mapToHomeIcon, color: Theme.of(context).primaryColor,
                        )),

                        Positioned(top: 0, bottom: 0, left: 5, right: 5,
                          child: SizedBox(width: 15,child: Image.asset(
                            Images.homeSmallIcon, color: Theme.of(context).colorScheme.shadow,
                          )),
                        )
                      ]),
                    ),
                  )),

                ]);
              }),
              persistentHeader: SizedBox(height: 50, child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: GetBuilder<RideController>(builder: (rideController) {
                  return InkWell(onTap: () => Get.to(()=> const RideRequestScreen()),
                    child: Container(
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: Dimensions.iconSizeSmall, child: Image.asset(Images.reqListIcon)),

                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Text(
                              '${rideController.pendingRideRequestModel?.totalSize??0} ${'more_request'.tr}',
                              style: textRegular.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })),
              ],
              )),
              expandableContent: Builder(builder: (context) {
                return Column(mainAxisSize: MainAxisSize.min,children: [
                  RiderBottomSheetWidget(expandableKey: key),

                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ]);
              }),
            );
          });
        }),
      ),
    );
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if(details.primaryVelocity == 0) return; // user have just tapped on screen (no dragging)

    if (details.primaryVelocity!.compareTo(0) == -1) {

    } else {

    }
  }

}