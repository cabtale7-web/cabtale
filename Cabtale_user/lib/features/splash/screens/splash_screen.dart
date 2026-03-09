import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/maintainance_mode/maintainance_screen.dart';
import 'package:ride_sharing_user_app/features/onboard/screens/onboarding_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/firebase_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:app_links/app_links.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  StreamSubscription? _sub;

  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _videoDone = false;
  bool _routeRequested = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    Get.find<ConfigController>().initSharedData();
    _handleIncomingLinks();
    _checkConnectivity();
  }

  // ---------------------- VIDEO INIT ---------------------------
  Future<void> _initVideo() async {
    try {
      _videoCtrl = VideoPlayerController.asset(
        'assets/animation/cabtale_splash.mp4',
      );

      await _videoCtrl!.initialize();
      _videoCtrl!.setLooping(false);
      setState(() => _videoReady = true);
      _videoCtrl!.play();

      _videoCtrl!.addListener(() {
        if (_videoCtrl == null || !_videoCtrl!.value.isInitialized) return;

        if (!_videoCtrl!.value.isPlaying &&
            _videoCtrl!.value.position >= _videoCtrl!.value.duration) {
          _videoDone = true;
          _tryNavigateAfterVideo();
        }
      });

      Future.delayed(const Duration(seconds: 4), () {
        if (!_videoDone) {
          _videoDone = true;
          _tryNavigateAfterVideo();
        }
      });
    } catch (e) {
      _videoDone = true;
      _tryNavigateAfterVideo();
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _onConnectivityChanged?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  // ------------------ CONNECTIVITY CHECK --------------------
  void _checkConnectivity() {
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((results) async {
      final isConnected = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);

      if (!isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("No internet connection"),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Internet connected"),
          duration: Duration(seconds: 2),
        ),
      );

      _handleIncomingLinks();
    });
  }

  // ------------------ HANDLE LINKS + CONFIG --------------------
  Future<void> _handleIncomingLinks() async {
    var status = await Connectivity().checkConnectivity();
    final isConnected = status.contains(ConnectivityResult.mobile) ||
        status.contains(ConnectivityResult.wifi);

    if (!isConnected) return;

    try {
      await Get.find<ConfigController>().getConfigData();
      Get.find<TripController>().getRideCancellationReasonList();
      Get.find<TripController>().getParcelCancellationReasonList();
      FirebaseHelper().subscribeFirebaseTopic();
    } catch (e) {
      debugPrint("⚠ API ERROR: $e");
      return;
    }

    final Uri? initial = await _appLinks.getInitialLink();

    if (initial != null) {
      _handleUri(initial);
    } else {
      _route();

      if (GetPlatform.isIOS) {
        _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
          if (uri != null) _handleUri(uri);
        });
      }
    }
  }

  void _handleUri(Uri uri) {
    final phone = uri.queryParameters['phone'] ?? "";
    final pass = uri.queryParameters['password'] ?? "";
    final code = uri.queryParameters['country_code'] ?? "";
    final fullNumber = "+${code.trim()}$phone";

    final auth = Get.find<AuthController>();
    final profile = Get.find<ProfileController>();

    if (auth.getUserToken().isNotEmpty) {
      profile.getProfileInfo().then((value) {
        if (value.statusCode == 200) {
          auth.updateToken();
          if (profile.profileModel?.data?.phone == fullNumber) {
            _route();
          } else {
            auth.externalLogin("+${code.trim()}", phone, pass);
            _route();
          }
        }
      });
    } else {
      auth.externalLogin("+${code.trim()}", phone, pass);
      _route();
    }
  }

  void _route() {
    _routeRequested = true;
    _tryNavigateAfterVideo();
  }

  // ----------------------- FINAL NAVIGATION ----------------------
  void _tryNavigateAfterVideo() {
    if (_hasNavigated || !_routeRequested || !_videoDone) return;
    _hasNavigated = true;

    final auth = Get.find<AuthController>();
    if (auth.getUserToken().isNotEmpty) {
      PusherHelper.initilizePusher();
    }

    Future.delayed(const Duration(milliseconds: 150), () {
      if (auth.isLoggedIn()) {
        _forLoginUserRoute();
      } else {
        _forNotLoginUserRoute();
      }
    });
  }

  // ------------------- NOT LOGGED IN USER ---------------------
  void _forNotLoginUserRoute() {
    final cfg = Get.find<ConfigController>().config;
    final maintenance = cfg?.maintenanceMode;
    final system = maintenance?.selectedMaintenanceSystem;

    final isMaintenanceOn =
        (maintenance?.maintenanceStatus == 1) &&
            (system?.userApp == 1);

    if (isMaintenanceOn) {
      Get.offAll(() => const MaintenanceScreen());
    } else if (Get.find<ConfigController>().showIntro()) {
      Get.offAll(() => const OnBoardingScreen());
    } else {
      Get.offAll(() => const SignInScreen());
    }
  }

  // ---------------------- LOGGED IN USER ---------------------
  void _forLoginUserRoute() {
    final loc = Get.find<LocationController>().getUserAddress();

    if (loc != null && loc.address != null && loc.address!.isNotEmpty) {
      Get.find<ProfileController>().getProfileInfo().then((value) {
        if (value.statusCode == 200) {
          final auth = Get.find<AuthController>();
          auth.updateToken();

          if (value.body['data']['is_profile_verified'] == 1) {
            auth.remainingFindingRideTime();
            Get.offAll(() => const DashboardScreen());
          } else {
            Get.offAll(() => const EditProfileScreen(fromLogin: true));
          }
        }
      });
    } else {
      Get.offAll(() => const AccessLocationScreen());
    }
  }

  // -------------------------- UI -------------------------------
  @override
  Widget build(BuildContext context) {
    final bg = Get.isDarkMode ? Colors.black : Colors.black;

    return Scaffold(
      body: Container(
        color: bg,
        width: double.infinity,
        height: double.infinity,
        child: (_videoReady &&
            _videoCtrl != null &&
            _videoCtrl!.value.isInitialized)
            ? FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoCtrl!.value.size.width,
            height: _videoCtrl!.value.size.height,
            child: VideoPlayer(_videoCtrl!),
          ),
        )
            : const SizedBox.expand(),
      ),
    );
  }
}
