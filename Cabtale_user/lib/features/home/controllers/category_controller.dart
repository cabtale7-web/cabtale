import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/categoty_model.dart';
import 'package:ride_sharing_user_app/features/home/domain/repositories/category_repo.dart';


// class CategoryController extends GetxController implements GetxService{
//   final CategoryRepo categoryRepo;
//   CategoryController({required this.categoryRepo});
//
//   List<Category>? categoryList;
//   bool isLoading = false;
//
//   Future<void> getCategoryList() async {
//     Response? response = await categoryRepo.getCategoryList();
//     if(response!.statusCode == 200 && response.body['data'] != null) {
//       categoryList = [];
//       categoryList!.addAll(CategoryModel.fromJson(response.body).data!);
//     }else{
//       ApiChecker.checkApi(response);
//     }
//     update();
//   }
//
// }

class CategoryController extends GetxController implements GetxService {
  final CategoryRepo categoryRepo;
  CategoryController({required this.categoryRepo});

  List<Category>? categoryList;
  bool isLoading = false;

  Future<void> getCategoryList() async {
    isLoading = true;
    update();

    Response? response = await categoryRepo.getCategoryList();

    if (response != null && response.statusCode == 200 && response.body['data'] != null) {
      // Map API response to Category objects with asset images
      categoryList = List<Category>.from(
          response.body['data'].map((x) => Category.fromJson(x)));
    } else {
      ApiChecker.checkApi(response!);
    }

    isLoading = false;
    update();
  }
}

