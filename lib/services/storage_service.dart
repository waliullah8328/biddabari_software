import 'dart:convert';
import 'package:get_storage/get_storage.dart';

import '../course_section/course_home/data/models/course_model.dart';



/// Local cache for course data.
///
/// This is what makes the app "offline-first": the last successful
/// API response is always available on disk, so the course_home page always
/// has something to show even with zero connectivity.
class StorageService {
  static const _coursesKey = 'cached_courses';
  static const _lastSyncKey = 'courses_last_synced_at';

  final _box = GetStorage();

  List<CourseModel> readCachedCourses() {
    final raw = _box.read<String>(_coursesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return CourseResponse.fromJson(decoded).courses;
    } catch (_) {
      return [];
    }
  }

  Future<void> cacheCourses(List<CourseModel> courses) async {
    final payload = jsonEncode(CourseResponse(courses: courses).toJson());
    await _box.write(_coursesKey, payload);
    await _box.write(_lastSyncKey, DateTime.now().toIso8601String());
  }

  DateTime? get lastSyncedAt {
    final raw = _box.read<String>(_lastSyncKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  bool get hasCache => (_box.read<String>(_coursesKey) ?? '').isNotEmpty;
}
