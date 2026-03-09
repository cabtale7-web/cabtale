import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/parcel_card_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';

class OngoingParcelListViewWidget extends StatefulWidget {
  final String title;
  const OngoingParcelListViewWidget({super.key, required this.title});

  @override
  State<OngoingParcelListViewWidget> createState() => _OngoingParcelListViewWidgetState();
}

class _OngoingParcelListViewWidgetState extends State<OngoingParcelListViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(title: widget.title.tr, regularAppbar: true,),
        body: GetBuilder<RideController>(builder: (rideController){
          return (rideController.parcelListModel == null || rideController.parcelListModel!.data!.isEmpty) ?
          const NoDataWidget(title: 'no_trip_found') :
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: rideController.parcelListModel!.data!.length,
              itemBuilder: (context, index){
                return ParcelRequestCardWidget(rideRequest: rideController.parcelListModel!.data![index], index: index);
              });
        })
    );
  }
}
