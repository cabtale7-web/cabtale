import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/categoty_model.dart';
import 'package:ride_sharing_user_app/helper/vehicle_helper.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/image_url_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CategoryWidget extends StatelessWidget {
  final Category category;
  final bool? isSelected;
  final bool fromSelect;
  final int index;
  final VoidCallback? onTap;
  final double? tileWidth;
  final double? tileImageHeight;
  final EdgeInsetsGeometry? tileMargin;

  const CategoryWidget({
    super.key,
    required this.category,
    this.isSelected,
    this.fromSelect = false,
    required this.index,
    this.onTap,
    this.tileWidth,
    this.tileImageHeight,
    this.tileMargin,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ImageUrlHelper.buildImageUrl(
      category.image,
      baseUrl:
          Get.find<ConfigController>().config?.imageBaseUrl?.vehicleCategory,
    );
    final String fallbackAsset = getVehicleAsset(category.name ?? category.id);
    final bool compactTile = tileWidth == double.infinity;

    return InkWell(
      onTap: () {
        Get.find<RideController>().setRideCategoryIndex(index);
        if (onTap != null) {
          onTap!();
        }
        if (!fromSelect) {
          Get.to(() => const SetDestinationScreen());
        }
      },
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: tileImageHeight ?? (isSelected != null ? 70 : 90),
              width: tileWidth ?? 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: (isSelected != null && isSelected!)
                    ? Theme.of(context).primaryColor.withOpacity(0.8)
                    : Theme.of(context).hintColor.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              margin: tileMargin ??
                  const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: ImageWidget(
                  image: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: fallbackAsset.isNotEmpty
                      ? fallbackAsset
                      : Images.carPlaceholder,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              category.name ?? '',
              textAlign: TextAlign.center,
              style: textSemiBold.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.8),
                fontSize: compactTile
                    ? Dimensions.fontSizeExtraSmall
                    : Dimensions.fontSizeSmall,
              ),
              maxLines: compactTile ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
