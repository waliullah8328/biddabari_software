import 'package:intl/intl.dart';

class CourseResponse {
  final List<CourseModel> courses;

  CourseResponse({required this.courses});

  factory CourseResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['courses'] as List<dynamic>? ?? [])
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return CourseResponse(courses: list);
  }

  Map<String, dynamic> toJson() => {
    'courses': courses.map((c) => c.toJson()).toList(),
  };
}

class CourseModel {
  final int id;
  final String title;
  final String subTitle;
  final int price;
  final String banner;
  final int discountType; // 1 = flat amount off, 2 = percentage off
  final int discountAmount;
  final String discountStartDate;
  final String discountEndDate;
  final String altText;
  final String bannerTitle;
  final String durationInMonth;
  final String totalClass;
  final int totalExam;
  final int totalLive;
  final String orderStatus;

  CourseModel({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.price,
    required this.banner,
    required this.discountType,
    required this.discountAmount,
    required this.discountStartDate,
    required this.discountEndDate,
    required this.altText,
    required this.bannerTitle,
    required this.durationInMonth,
    required this.totalClass,
    required this.totalExam,
    required this.totalLive,
    required this.orderStatus,
  });

  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd HH:mm');

  DateTime? get discountStartDateTime {
    if (discountStartDate.isEmpty) return null;
    try {
      return _apiDateFormat.parse(discountStartDate);
    } catch (_) {
      return null;
    }
  }

  DateTime? get discountEndDateTime {
    if (discountEndDate.isEmpty) return null;
    try {
      return _apiDateFormat.parse(discountEndDate);
    } catch (_) {
      return null;
    }
  }

  /// Final payable price after the discount is applied.
  int get discountedPrice {
    if (discountType == 1) {
      final result = price - discountAmount;
      return result < 0 ? 0 : result;
    } else if (discountType == 2) {
      final result = price - ((price * discountAmount) / 100).round();
      return result < 0 ? 0 : result;
    }
    return price;
  }

  /// There's a discount amount configured at all (ignores dates).
  bool get hasDiscount => discountAmount > 0 && discountedPrice < price;

  /// The offer is actually running right now (has a discount AND we're
  /// currently inside [discountStartDate, discountEndDate]).
  /// Falls back to just checking the end date if the start date can't be
  /// parsed, so a bad/missing start date never hides a real offer.
  bool get isOfferLive {
    if (!hasDiscount) return false;
    final end = discountEndDateTime;
    if (end == null) return false;
    final now = DateTime.now();
    if (now.isAfter(end)) return false;
    final start = discountStartDateTime;
    if (start != null && now.isBefore(start)) return false;
    return true;
  }

  /// Remaining time until the offer ends, or null if there's no live offer.
  Duration? get timeUntilOfferEnds {
    if (!isOfferLive) return null;
    return discountEndDateTime!.difference(DateTime.now());
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

    return CourseModel(
      id: _int(json['id']),
      title: json['title']?.toString() ?? '',
      subTitle: json['sub_title']?.toString() ?? '',
      price: _int(json['price']),
      // Trim defensively: stray whitespace/newlines in a URL string is a
      // common, easy-to-miss reason an image silently fails to load.
      banner: json['banner']?.toString().trim() ?? '',
      discountType: _int(json['discount_type']),
      discountAmount: _int(json['discount_amount']),
      discountStartDate: json['discount_start_date']?.toString() ?? '',
      discountEndDate: json['discount_end_date']?.toString() ?? '',
      altText: json['alt_text']?.toString() ?? '',
      bannerTitle: json['banner_title']?.toString() ?? '',
      durationInMonth: json['duration_in_month']?.toString() ?? '',
      totalClass: json['total_class']?.toString() ?? '',
      totalExam: _int(json['total_exam']),
      totalLive: _int(json['total_live']),
      orderStatus: json['order_status']?.toString() ?? 'false',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'sub_title': subTitle,
    'price': price,
    'banner': banner,
    'discount_type': discountType,
    'discount_amount': discountAmount,
    'discount_start_date': discountStartDate,
    'discount_end_date': discountEndDate,
    'alt_text': altText,
    'banner_title': bannerTitle,
    'duration_in_month': durationInMonth,
    'total_class': totalClass,
    'total_exam': totalExam,
    'total_live': totalLive,
    'order_status': orderStatus,
  };
}