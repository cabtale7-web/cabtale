import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/firebase_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';

import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/screens/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/maintainance_mode/screens/maintainance_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';

import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _videoDone = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  bool _routeRequested = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    if (!GetPlatform.isIOS) {
      _checkConnectivity();
    }

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeCtrl)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _videoDone = true;
          _tryNavigateAfterVideo();
        }
      });

    _initVideo();

    Get.find<SplashController>().initSharedData();
    Get.find<TripController>().rideCancellationReasonList();
    Get.find<TripController>().parcelCancellationReasonList();
    Get.find<AuthController>().remainingTime();

    _route();
  }

  Future<void> _initVideo() async {
    _videoCtrl = VideoPlayerController.asset('assets/animation/cabtale_splash.mp4');
    try {
      await _videoCtrl!.initialize();
      await _videoCtrl!.setLooping(false);
      setState(() => _videoReady = true);
      _videoCtrl!.play();

      _videoCtrl!.addListener(() {
        if (_videoCtrl!.value.isInitialized &&
            !_videoCtrl!.value.isPlaying &&
            (_videoCtrl!.value.position >= _videoCtrl!.value.duration)) {
          _videoDone = true;
          _tryNavigateAfterVideo();
        }
      });

      Future.delayed(const Duration(seconds: 6), () {
        if (mounted && !_videoDone) _fadeCtrl.forward();
      });

      Future.delayed(const Duration(milliseconds: 7500), () {
        if (!_videoDone) {
          _videoDone = true;
          _tryNavigateAfterVideo();
        }
      });
    } catch (_) {
      _videoDone = true;
      _tryNavigateAfterVideo();
    }
  }

  @override
  void dispose() {
    _onConnectivityChanged?.cancel();
    _fadeCtrl.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  void _checkConnectivity() {
    bool isFirst = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);
      if ((isFirst && !isConnected) || !isFirst && context.mounted) {
        ScaffoldMessenger.of(Get.context!).removeCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
        ));
        if (isConnected) {
          _route();
        }
      }
      isFirst = false;
    });
  }

  void _route() async {
    bool isSuccess = await Get.find<SplashController>().getConfigData();
    if (isSuccess) {
      FirebaseHelper().subscribeFirebaseTopic();
      if (Get.find<AuthController>().getUserToken().isNotEmpty) {
        PusherHelper.initilizePusher();
      }
      if (Get.find<AuthController>().getZoneId() == '') {
        _routeRequested = true;
        _tryNavigateAfterVideo();
      } else {
        Get.find<AuthController>().updateToken();
        Future.delayed(const Duration(milliseconds: 1000), () {
          _routeRequested = true; // signal ready to navigate after video
          if (Get.find<AuthController>().isLoggedIn()) {
            Get.find<ProfileController>().getProfileInfo().then((value) {
              if (value.statusCode == 200) {
                Get.find<LocationController>().getCurrentLocation().then((_) {
                  // target: Dashboard
                  _tryNavigateAfterVideo(target: const DashboardScreen());
                });
                PusherHelper().driverTripRequestSubscribe(value.body['data']['id']);
              }
            });
          } else {
            _tryNavigateAfterVideo();
          }
        });
      }
    }
  }

  void _tryNavigateAfterVideo({Widget? target}) {
    if (_hasNavigated) return;
    if (!_routeRequested) return;
    if (!_videoDone) return;

    _hasNavigated = true;

    if (target != null) {
      Get.offAll(() => target);
      return;
    }

    if (Get.find<AuthController>().getZoneId() == '') {
      Get.offAll(() => const AccessLocationScreen());
      return;
    }

    if (Get.find<AuthController>().isLoggedIn()) {
      Get.offAll(() => const DashboardScreen());
      return;
    } else {
      final cfg = Get.find<SplashController>().config;
      if (cfg?.maintenanceMode != null &&
          cfg!.maintenanceMode!.maintenanceStatus == 1 &&
          cfg.maintenanceMode!.selectedMaintenanceSystem!.driverApp == 1) {
        Get.offAll(() => const MaintenanceScreen());
      } else {
        Get.offAll(() => const SignInScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).primaryColorDark;
    return Scaffold(
      body: GetBuilder<RideController>(builder: (_) {
        return GetBuilder<ProfileController>(builder: (_) {
          return GetBuilder<LocationController>(builder: (_) {
            return Container(
              color: bg,
              width: double.infinity,
              height: double.infinity,
              child: _videoReady && _videoCtrl != null
                  ? Stack(
                    fit: StackFit.expand,
                    children: [
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoCtrl!.value.size.width,
                          height: _videoCtrl!.value.size.height,
                          child: VideoPlayer(_videoCtrl!),
                        ),
                      ),
                      // Black overlay that fades in during last second
                      FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(_fadeCtrl),
                        child: Container(color: Colors.black),
                      ),
                    ],
                  )
                  : const SizedBox.expand(),
            );
          });
        });
      }),
    );
  }
}
