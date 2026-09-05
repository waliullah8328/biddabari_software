import 'package:biddabari_software/course_section/course_home/presentation/widgets/course_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common_widgets/offline_banner.dart';
import '../../../core/common_widgets/offline_full_screen.dart';
import '../../../routes/app_routes.dart';

import '../data/models/course_model.dart';
import '../logic/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const _primaryColor = Color(0xFF1565C0);
  static const _backgroundColor = Color(0xFFF6F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biddabari',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              'Explore your courses',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => controller.isRefreshing.value
                ? const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                    ),
                  )
                : IconButton(
                    tooltip: 'Refresh',
                    onPressed: controller.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => controller.isOffline
                ? const OfflineBanner()
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const _LoadingState();
              }

              if (controller.courses.isEmpty) {
                if (controller.isOffline) {
                  return OfflineFullScreen(onRetry: controller.retry);
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _ErrorState(
                    message: controller.errorMessage.value,
                    onRetry: controller.retry,
                  );
                }

                return const _EmptyState();
              }

              return RefreshIndicator(
                color: _primaryColor,
                onRefresh: controller.refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                  itemCount: controller.courses.length,
                  itemBuilder: (context, index) {
                    return _CourseCard(course: controller.courses[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;

  const _CourseCard({required this.course});

  static const _primaryColor = Color(0xFF1565C0);
  static const _greenColor = Color(0xFF16863E);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.courseDetails, arguments: course);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CourseBanner(
                  courseId: course.id,
                  imageUrl: course.banner,
                  aspectRatio: 16 / 9.5,
                  offerEndTime: course.isOfferLive
                      ? course.discountEndDateTime
                      : null,
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course title
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.25,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        course.subTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Price section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '৳${course.discountedPrice}',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: _greenColor,
                              letterSpacing: -0.5,
                            ),
                          ),

                          if (course.hasDiscount) ...[
                            const SizedBox(width: 9),
                            Text(
                              '৳${course.price}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _DiscountBadge(amount: course.discountAmount),
                          ],

                          const Spacer(),

                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _primaryColor.withValues(alpha: 0.09),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Container(height: 1, color: Colors.grey.shade100),

                      const SizedBox(height: 14),

                      // Course statistics
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: Icons.schedule_rounded,
                              value: '${course.durationInMonth}',
                              label: 'Months',
                            ),
                          ),
                          _VerticalDivider(),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.live_tv_rounded,
                              value: '${course.totalLive}',
                              label: 'Live',
                            ),
                          ),
                          _VerticalDivider(),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.menu_book_rounded,
                              value: '${course.totalClass}',
                              label: 'Classes',
                            ),
                          ),
                          _VerticalDivider(),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.quiz_rounded,
                              value: '${course.totalExam}',
                              label: 'Exams',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final dynamic amount;

  const _DiscountBadge({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        'Save ৳$amount',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.red.shade700,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey.shade500),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: Colors.grey.shade200);
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 38,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No courses found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'There are no courses available right now.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
