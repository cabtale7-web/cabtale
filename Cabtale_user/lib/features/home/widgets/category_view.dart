import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/category_widget.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/category_shimmer.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController) {
      final list = categoryController.categoryList;

      if (list == null) {
        return const SizedBox(
          height: 105,
          child: CategoryShimmer(),
        );
      }

      if (list.isEmpty) {
        return SizedBox(
          height: 105,
          child: Center(child: Text('no_category_found'.tr)),
        );
      }

      return SizedBox(
        height: 130,
        width: double.infinity,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) => CategoryWidget(
            index: index,
            category: list[index],
            tileMargin: EdgeInsets.zero,
          ),
        ),
      );
    });
  }
}
