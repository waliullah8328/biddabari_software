import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/course_model.dart';

class CourseApiProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://api.biddabari.com/api/v1';
    httpClient.timeout = const Duration(seconds: 15);

    httpClient.addRequestModifier<dynamic>((request) {
      debugPrint('➡️ REQUEST: ${request.method} ${request.url}');
      return request;
    });

    httpClient.addResponseModifier<dynamic>((request, response) {
      debugPrint('⬅️ RESPONSE: ${response.statusCode}');
      debugPrint('⬅️ BODY: ${response.body}');
      return response;
    });

    super.onInit();
  }

  Future<CourseResponse> getHomeCourses() async {
    const endpoint = '/app-home-courses';

    debugPrint('🌐 Calling: ${httpClient.baseUrl}$endpoint');

    final response = await get(endpoint);

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.hasError) {
      throw Exception(
        'API Error ${response.statusCode}: '
            '${response.statusText ?? 'Unknown error'}',
      );
    }

    final body = response.body;

    if (body is Map<String, dynamic>) {
      return CourseResponse.fromJson(body);
    }

    throw Exception(
      'Unexpected response format: ${body.runtimeType}',
    );
  }
}