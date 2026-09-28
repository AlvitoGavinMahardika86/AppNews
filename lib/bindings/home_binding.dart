import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/controllers/saved_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsController>(() => NewsController());
    Get.lazyPut<SavedController>(() => SavedController());
  }
}
