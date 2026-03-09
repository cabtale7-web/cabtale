import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_shimmer.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';


class HomeMapView extends StatefulWidget {
  final String title;
  const HomeMapView({super.key, required this.title});

  @override
  HomeMapViewState createState() => HomeMapViewState();
}

class HomeMapViewState extends State<HomeMapView> {
  GoogleMapController? _mapController;
  int isFirstCount = 0;


  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapController>(builder: (mapController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        return mapController.nearestDeliveryManMarkers != null ?
        Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          child: Column(children: [
            const SizedBox(height:Dimensions.paddingSizeSmall),

            Container(height: Get.height * 0.20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                child: GoogleMap(
                  style: Get.isDarkMode ?
                  Get.find<ThemeController>().darkMap :
                  Get.find<ThemeController>().lightMap,
                  markers: mapController.nearestDeliveryManMarkers!.toSet(),
                  initialCameraPosition: CameraPosition(target: LatLng(
                    locationController.getUserAddress()?.latitude ?? locationController.initialPosition.latitude,
                    locationController.getUserAddress()?.longitude ?? locationController.initialPosition.longitude,
                  ), zoom: 17.2),
                  minMaxZoomPreference: const MinMaxZoomPreference(5, 19),
                  onMapCreated: (gController) {
                    _mapController = gController;
                    calculateCenterBound(
                      locationController.getUserAddress()?.latitude ?? locationController.initialPosition.latitude,
                      locationController.getUserAddress()?.longitude ?? locationController.initialPosition.longitude,
                    );
                    mapController.setMapController(gController);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: false,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                  },
                ),
              ),
            ),
          ]),
        ) :
        const BannerShimmer();
      });
    });
  }


  LatLng calculateCenterBound(double lat, double lng){
    final LatLng center = _resolveHomeCenter(lat, lng);
    final List<LatLng> list = _buildVisiblePoints(center);
    LatLngBounds bounds = Get.find<MapController>().boundWithMaximumLatLngPoint(list);
    LatLng centerBounds = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude)/2,
      (bounds.northeast.longitude + bounds.southwest.longitude)/2,
    );

    if(isFirstCount == 0){
      isFirstCount++;
      Get.find<MapController>().zoomToFit(_mapController, bounds, centerBounds, 0, padding: 0.35);
    }
    return centerBounds;
  }

  LatLng _resolveHomeCenter(double lat, double lng) {
    if (lat != 0 || lng != 0) {
      return LatLng(lat, lng);
    }

    final Marker? firstMarker = Get.find<MapController>().nearestDeliveryManMarkers?.isNotEmpty == true
        ? Get.find<MapController>().nearestDeliveryManMarkers!.first
        : null;
    return firstMarker?.position ?? const LatLng(0, 0);
  }

  List<LatLng> _buildVisiblePoints(LatLng center) {
    final List<LatLng> points = <LatLng>[center];
    final List<Marker> markers =
        Get.find<MapController>().nearestDeliveryManMarkers?.toList() ?? <Marker>[];

    for (final Marker marker in markers.take(6)) {
      points.add(marker.position);
    }

    if (points.length == 1) {
      final double searchRadius = min(
        (Get.find<ConfigController>().config?.searchRadius ?? 0) / 8,
        1.2,
      );
      final double fallbackRadius = searchRadius > 0 ? searchRadius : 0.6;
      points.add(calculateOffset(center, fallbackRadius, 270));
      points.add(calculateOffset(center, fallbackRadius, 90));
      points.add(calculateOffset(center, fallbackRadius, 180));
      points.add(calculateOffset(center, fallbackRadius, 360));
    }

    return points;
  }


  LatLng calculateOffset(LatLng center, double distance, double bearing) {
    const double earthRadius = 6371.0; // Radius of the Earth in kilometers
    double radLat = radians(center.latitude);
    double radLon = radians(center.longitude);
    double radBearing = radians(bearing);
    double newLat = asin(sin(radLat) * cos(distance / earthRadius) +
        cos(radLat) * sin(distance / earthRadius) * cos(radBearing));
    double newLon = radLon +
        atan2(sin(radBearing) * sin(distance / earthRadius) * cos(radLat),
            cos(distance / earthRadius) - sin(radLat) * sin(newLat));
    return LatLng(degrees(newLat), degrees(newLon));
  }
  double radians(double degrees) {
    return degrees * pi / 180;
  }
  double degrees(double radians) {
    return radians * 180 / pi;
  }

}
