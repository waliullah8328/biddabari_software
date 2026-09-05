import 'package:get/get.dart';

import '../../../services/storage_service.dart';
import '../../course_home/data/providers/course_api_provider.dart';
import '../../course_home/data/repositories/course_repository.dart';
import '../logic/course_details_controller.dart';

class CourseDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseApiProvider>(() => CourseApiProvider(), fenix: true);
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<CourseRepository>(
      () => CourseRepository(Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut<CourseDetailsController>(
      () => CourseDetailsController(Get.find()),
    );
  }
}
