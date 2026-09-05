import 'package:get/get.dart';

import '../../course_home/data/models/course_model.dart';
import '../../course_home/data/repositories/course_repository.dart';

class CourseDetailsController extends GetxController {
  final CourseRepository _repository;
  CourseDetailsController(this._repository);

  late final Rx<CourseModel?> course;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    CourseModel? initial;

    if (arg is CourseModel) {
      // Fast path: came from tapping a card on the home page, no lookup
      // needed and it works whether we're online or offline.
      initial = arg;
    } else if (arg is int) {
      initial = _repository.findById(arg);
    } else if (Get.parameters['id'] != null) {
      // Supports deep links like /course-details?id=2057
      final id = int.tryParse(Get.parameters['id']!);
      if (id != null) initial = _repository.findById(id);
    }

    course = Rx<CourseModel?>(initial);
  }
}
