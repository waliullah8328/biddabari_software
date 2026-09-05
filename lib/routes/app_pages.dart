import 'package:get/get.dart';
import '../course_section/course_details/bindings/course_details_binding.dart';
import '../course_section/course_details/presentation/course_details_view.dart';

import '../course_section/course_home/bindings/home_binding.dart';
import '../course_section/course_home/presentation/home_view.dart';



import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.courseDetails,
      page: () => const CourseDetailsView(),
      binding: CourseDetailsBinding(),
    ),
  ];
}
