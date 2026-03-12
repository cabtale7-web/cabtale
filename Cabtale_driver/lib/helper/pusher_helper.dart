import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/payment_received_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/review_this_customer_screen.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

import '../features/dashboard/screens/dashboard_screen.dart';


class PusherHelper{

  static PusherChannelsClient?  pusherClient;

  static String _socketHost() {
    final String raw = (Get.find<SplashController>().config?.webSocketUrl ?? '').trim();
    if (raw.isEmpty) {
      return '';
    }
    return raw.replaceFirst(RegExp(r'^https?://'), '').replaceAll('/', '');
  }

  static String _socketScheme() {
    final String raw = (Get.find<SplashController>().config?.webSocketUrl ?? '').trim().toLowerCase();
    return raw.startsWith('https://') ? 'wss' : 'ws';
  }

  static Uri _authEndpoint() {
    final String raw = (Get.find<SplashController>().config?.webSocketUrl ?? '').trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return Uri.parse('$raw/broadcasting/auth');
    }
    return Uri.parse('https://${_socketHost()}/broadcasting/auth');
  }

  bool _isPusherConnected() {
    return pusherClient != null && Get.find<SplashController>().pusherConnectionStatus == 'Connected';
  }

  static initilizePusher() async{
    final String socketHost = _socketHost();
    if (socketHost.isEmpty) {
      Get.find<SplashController>().setPusherStatus('Disconnected');
      return;
    }

    PusherChannelsOptions testOptions = PusherChannelsOptions.fromHost(
      host: socketHost,
      scheme: _socketScheme(),
      key: Get.find<SplashController>().config?.webSocketKey ?? AppConstants.appKey,
      port: int.parse(Get.find<SplashController>().config?.webSocketPort ?? '6001'),
    );
    pusherClient = PusherChannelsClient.websocket(
      options: testOptions,
      connectionErrorHandler: (exception, trace, refresh) async {
        //log('=================$exception');
        Get.find<SplashController>().setPusherStatus('Disconnected');
        refresh();
      },
    );

     await pusherClient?.connect();

    String? pusherChannelId =  pusherClient?.channelsManager.channelsConnectionDelegate.socketId;
      if(pusherChannelId != null){
        Get.find<SplashController>().setPusherStatus('Connected');
      }


     pusherClient?.lifecycleStream.listen((event) {
       final String eventText = event.toString().toLowerCase();
       if (eventText.contains('connected')) {
         Get.find<SplashController>().setPusherStatus('Connected');
       } else if (eventText.contains('disconnect') || eventText.contains('error') || eventText.contains('closed')) {
         Get.find<SplashController>().setPusherStatus('Disconnected');
       }
     });


  }


/// Pusher Client   pusher_client_fixed: ^0.0.2+3

/*  static PusherClient? pusherClient;
  static initilizePusher(String? token){
    print('====   ===>  $token');
    pusherClient = PusherClient(autoConnect: false,

        AppConstants.appKey,
         PusherOptions(
          host: Get.find<SplashController>().config!.webSocketUrl,
          wsPort: int.parse(Get.find<SplashController>().config!.webSocketPort!),
          wssPort: int.parse(Get.find<SplashController>().config!.webSocketPort!),
          auth: PusherAuth(
            'https://${Get.find<SplashController>().config!.webSocketUrl}/broadcasting/auth',
            headers: {'Authorization': 'Bearer $token'})),
    );

    pusherClient!.connect();
    pusherClient!.onConnectionStateChange((state) {
      print("previousState: ${state?.previousState}, currentState: ${state?.currentState}, socketId: ${pusherClient!.getSocketId()}",);
      Get.find<SplashController>().setPusherStatus(state?.currentState);
    });
  }*/

  late PrivateChannel customerCouponApplied;
  late PrivateChannel customerCouponRemoved;


  void customerCouponAppliedOrRemoved(String tripId){
    if (_isPusherConnected()){
      customerCouponApplied = pusherClient!.privateChannel("private-customer-coupon-applied.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: _authEndpoint(),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));
      if(customerCouponApplied.currentStatus == null){
        customerCouponApplied.subscribeIfNotUnsubscribed();
        customerCouponApplied.bind("customer-coupon-applied.$tripId").listen((event) {
          Get.find<RideController>().getFinalFare(jsonDecode(event.data!)['id']);
        });
      }


      customerCouponRemoved = pusherClient!.privateChannel("private-customer-coupon-removed.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: _authEndpoint(),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(customerCouponRemoved.currentStatus == null){
        customerCouponRemoved.subscribeIfNotUnsubscribed();
        customerCouponRemoved.bind("customer-coupon-removed.$tripId").listen((event) {
          Get.find<RideController>().getFinalFare(jsonDecode(event.data!)['id']);
        });
      }
    }


  }

  late PrivateChannel driverTripSubscribe;
  Future<void> driverTripRequestSubscribe(String id) async {
    if (!_isPusherConnected()) {
      await initilizePusher();
    }

    if (_isPusherConnected()){
      driverTripSubscribe = pusherClient!.privateChannel("private-customer-trip-request.$id", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: _authEndpoint(),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(driverTripSubscribe.currentStatus == null){
        driverTripSubscribe.subscribeIfNotUnsubscribed();
        driverTripSubscribe.bind("customer-trip-request.$id").listen((event) {
          AudioPlayer audio = AudioPlayer();
          audio.play(AssetSource('notification.wav'));
          Get.find<RideController>().getPendingRideRequestList(1);
          Get.find<RideController>().setRideId(jsonDecode(event.data!)['trip_id']);
          Get.find<RideController>().getRideDetailBeforeAccept(jsonDecode(event.data!)['trip_id']).then((value){
            if(value.statusCode == 200){
              Get.find<RiderMapController>().getPickupToDestinationPolyline();
              Get.find<RiderMapController>().setRideCurrentState(RideState.pending);
              Get.find<RideController>().updateRoute(false, notify: true);
              Get.to(()=> const MapScreen());
            }
          });

          customerInitialTripCancel(jsonDecode(event.data!)['trip_id'], id);
          anotherDriverAcceptedTrip(jsonDecode(event.data!)['trip_id'], id);
        });
      }
    }

  }

  late PrivateChannel customerInitialTripCancelChannel;

  void customerInitialTripCancel(String tripId, String userId){
    if (_isPusherConnected()){
      customerInitialTripCancelChannel = pusherClient!.privateChannel("private-customer-trip-cancelled.$tripId.$userId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: _authEndpoint(),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(customerInitialTripCancelChannel.currentStatus == null){
        customerInitialTripCancelChannel.subscribe();
        customerInitialTripCancelChannel.bind("customer-trip-cancelled.$tripId.$userId").listen((event) {
          Get.find<RideController>().getPendingRideRequestList(1).then((value){
            if(value.statusCode == 200){
              Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
              Get.find<RideController>().clearLastRideDetails();
              Get.offAll(()=> const DashboardScreen());
            }
          });
          // pusherClient!.unsubscribe('private-customer-trip-cancelled.$tripId.$userId');
        });
      }
    }

  }


  late PrivateChannel anotherDriverAcceptedTripChannel;

  void anotherDriverAcceptedTrip(String tripId, String userId){
    if (_isPusherConnected()){
      anotherDriverAcceptedTripChannel = pusherClient!.privateChannel("private-another-driver-trip-accepted.$tripId.$userId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: _authEndpoint(),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(anotherDriverAcceptedTripChannel.currentStatus == null){
        anotherDriverAcceptedTripChannel.subscribe();
        anotherDriverAcceptedTripChannel.bind("another-driver-trip-accepted.$tripId.$userId").listen((event) {
          Get.find<RideController>().getPendingRideRequestList(1).then((value){
            if(value.statusCode == 200){
              Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
              Get.offAll(()=> const DashboardScreen());
            }
          });
          // pusherClient!.unsubscribe('private-another-driver-trip-accepted.$tripId.$userId');
        });
      }
    }
  }

  late PrivateChannel tripCancelAfterOngoingChannel;

  void tripCancelAfterOngoing(String tripId){
    if (_isPusherConnected()){
      tripCancelAfterOngoingChannel = pusherClient!.privateChannel("private-customer-trip-cancelled-after-ongoing.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: _authEndpoint(),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(tripCancelAfterOngoingChannel.currentStatus == null){
        tripCancelAfterOngoingChannel.subscribe();
        tripCancelAfterOngoingChannel.bind("customer-trip-cancelled-after-ongoing.$tripId").listen((event) {
          Get.find<RideController>().getRideDetails(jsonDecode(event.data!)['id']).then((value){
            if(value.statusCode == 200){
              Get.find<RideController>().getFinalFare(jsonDecode(event.data!)['id']).then((value){
                if(value.statusCode == 200){
                  Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
                  Get.to(()=> const PaymentReceivedScreen());
                }
              });
            }
          });
          // pusherClient!.unsubscribe('private-customer-trip-cancelled-after-ongoing.$tripId');
        });
      }
    }

  }

  late PrivateChannel tripPaymentSuccessfulChannel;

  void tripPaymentSuccessful(String tripId){
    if (_isPusherConnected()){
      tripPaymentSuccessfulChannel = pusherClient!.privateChannel("private-customer-trip-payment-successful.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: _authEndpoint(),
        headers:  {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods':"PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      if(tripPaymentSuccessfulChannel.currentStatus == null){
        tripPaymentSuccessfulChannel.subscribe();
        tripPaymentSuccessfulChannel.bind("customer-trip-payment-successful.$tripId").listen((event) {
          if(jsonDecode(event.data!)['type']=='parcel'){
            Get.find<RideController>().getRideDetails(jsonDecode(event.data!)['id']).then((value){
              if(value.statusCode == 200){
                Get.find<RideController>().getOngoingParcelList();
                Get.back();
              }
            });
          }else{
            Get.find<RideController>().getRideDetails(jsonDecode(event.data!)['id']).then((value){
              if(value.statusCode == 200){
                if(Get.find<SplashController>().config!.reviewStatus!){
                  Get.offAll(()=>  ReviewThisCustomerScreen(tripId: jsonDecode(event.data!)['id']));
                }else{
                  Get.offAll(()=> const DashboardScreen());
                }
              }
            });
          }
          // pusherClient!.unsubscribe('private-customer-trip-payment-successful.$tripId');
        });
      }
    }

  }




  void pusherDisconnectPusher(){
    pusherClient?.disconnect();
    Get.find<SplashController>().setPusherStatus('Disconnected');
  }


}