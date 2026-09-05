import '../../../../services/storage_service.dart';
import '../models/course_model.dart';
import '../providers/course_api_provider.dart';


/// Single source of truth for course data.
///
/// Combines the remote API with the local cache so logic never
/// have to know (or care) whether data came from the network or disk.
class CourseRepository {
  final CourseApiProvider _provider;
  final StorageService _storage;

  CourseRepository(this._provider, this._storage);

  List<CourseModel> getCachedCourses() => _storage.readCachedCourses();

  DateTime? get lastSyncedAt => _storage.lastSyncedAt;

  bool get hasCache => _storage.hasCache;

  /// Fetches fresh data from the API and updates the local cache.
  /// Throws if the network call fails - callers decide how to handle it.
  Future<List<CourseModel>> fetchFromApi() async {
    final response = await _provider.getHomeCourses();
    await _storage.cacheCourses(response.courses);
    return response.courses;
  }

  /// Looks a course up from whatever is currently cached, used by the
  /// details page so it also works offline once the list was loaded once.
  CourseModel? findById(int id) {
    try {
      return getCachedCourses().firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
