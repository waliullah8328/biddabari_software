import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widgets/offline_banner.dart';

import '../../../services/connectivity_service.dart';
import '../../course_home/presentation/widgets/course_banner.dart';
import '../logic/course_details_controller.dart';

class CourseDetailsView extends GetView<CourseDetailsController> {
  const CourseDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Course Details')),
      body: Column(
        children: [
          Obx(() => connectivity.isOnline.value
              ? const SizedBox.shrink()
              : const OfflineBanner()),
          Expanded(
            child: Obx(() {
              final course = controller.course.value;
              if (course == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      "Course details aren't available offline yet.\n"
                          'Connect to the internet once to load this course.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: CourseBanner(
                        courseId: course.id,
                        imageUrl: course.banner,
                        aspectRatio: 16 / 9,
                        offerEndTime: course.isOfferLive
                            ? course.discountEndDateTime
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(course.subTitle,
                              style: TextStyle(color: Colors.grey.shade700)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                '৳${course.discountedPrice}',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E8E3E)),
                              ),
                              if (course.hasDiscount) ...[
                                const SizedBox(width: 10),
                                Text(
                                  '৳${course.price}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey.shade500),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Save ৳${course.discountAmount}',
                                    style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (course.hasDiscount) ...[
                            const SizedBox(height: 4),
                            Text(
                              course.isOfferLive
                                  ? 'Offer ends ${course.discountEndDate}'
                                  : 'Offer ended ${course.discountEndDate}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                          const Divider(height: 32),
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              _InfoChip(
                                  icon: Icons.calendar_month_outlined,
                                  label: '${course.durationInMonth} Months'),
                              _InfoChip(
                                  icon: Icons.videocam_outlined,
                                  label: '${course.totalLive} Live Classes'),
                              _InfoChip(
                                  icon: Icons.class_outlined,
                                  label: '${course.totalClass} Classes'),
                              _InfoChip(
                                  icon: Icons.quiz_outlined,
                                  label: '${course.totalExam} Exams'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        final course = controller.course.value;

        if (course == null) {
          return const SizedBox.shrink();
        }

        return _BottomEnrollBar(
          price: course.discountedPrice,
          hasDiscount: course.hasDiscount,
          onPressed: () {
            Get.snackbar(
              'Enroll',
              'Enrollment flow goes here',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
      }),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}


class _BottomEnrollBar extends StatelessWidget {
  final dynamic price;
  final bool hasDiscount;
  final VoidCallback onPressed;

  const _BottomEnrollBar({
    required this.price,
    required this.hasDiscount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 22,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Course Price',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '৳$price',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,

                    ),
                  ),
                ],
              ),
            ),

            // Enroll button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(


                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enroll Now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
