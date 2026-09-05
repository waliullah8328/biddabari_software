import 'package:get/get.dart';

import '../../../services/connectivity_service.dart';
import '../../../services/storage_service.dart';

import '../data/providers/course_api_provider.dart';
import '../data/repositories/course_repository.dart';
import '../logic/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<CourseApiProvider>(() => CourseApiProvider(), fenix: true);
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<CourseRepository>(
      () => CourseRepository(Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find(), Get.find<ConnectivityService>()),
    );
  }
}
