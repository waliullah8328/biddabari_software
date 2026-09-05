import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'offer_coundown_chip_widget.dart';





class CourseBanner extends StatelessWidget {
  final int courseId;
  final String imageUrl;
  final double aspectRatio;
  final DateTime? offerEndTime;

  const CourseBanner({
    super.key,
    required this.courseId,
    required this.imageUrl,
    this.aspectRatio = 16 / 8,
    this.offerEndTime,
  });

  String _getStorageUrl(String url) {
    const oldBaseUrl = 'https://api.biddabari.com/';
    const newBaseUrl =
        'https://storage.biddabari.online/biddabari-bucket/';

    final trimmedUrl = url.trim();

    if (trimmedUrl.startsWith(oldBaseUrl)) {
      return trimmedUrl.replaceFirst(oldBaseUrl, newBaseUrl);
    }

    return trimmedUrl;
  }

  @override
  Widget build(BuildContext context) {
    final storageImageUrl = _getStorageUrl(imageUrl);

    debugPrint('🖼️ Original image URL: $imageUrl');
    debugPrint('🖼️ Storage image URL: $storageImageUrl');

    return Hero(
      tag: 'course-banner-$courseId',
      child: Stack(
        children: [
          _BannerImage(
            url: storageImageUrl,
            aspectRatio: aspectRatio,
          ),

          if (offerEndTime != null)
            Positioned(
              right: 10,
              top: 6,
              child: OfferCountdownChip(
                endTime: offerEndTime!,
              ),
            ),
        ],
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  final String url;
  final double aspectRatio;

  const _BannerImage({
    required this.url,
    required this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.image_not_supported_outlined,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: CachedNetworkImage(
        imageUrl: url,

        // Important: use the final storage URL as cache key.
        cacheKey: url,

        fit: BoxFit.fitWidth,

        fadeInDuration: const Duration(
          milliseconds: 150,
        ),

        progressIndicatorBuilder: (
            context,
            url,
            progress,
            ) {
          return Container(
            color: Colors.grey.shade200,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress.progress,
                ),
              ),
            ),
          );
        },

        errorWidget: (
            context,
            url,
            error,
            ) {
          if (kDebugMode) {
            debugPrint(
              '❌ Banner image failed to load:\n'
                  'URL: $url\n'
                  'Reason: $error',
            );
          }

          return Container(
            color: Colors.grey.shade200,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                ),
                SizedBox(height: 4),
                Text(
                  'Image unavailable',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}