import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../services/connectivity_service.dart';
import '../data/models/course_model.dart';
import '../data/repositories/course_repository.dart';

class HomeController extends GetxController {
  final CourseRepository _repository;
  final ConnectivityService _connectivity;

  HomeController(
      this._repository,
      this._connectivity,
      );

  // ===========================================================================
  // STATE
  // ===========================================================================

  final RxList<CourseModel> courses = <CourseModel>[].obs;

  /// First API loading when there is no cached data.
  final RxBool isLoading = false.obs;

  /// API refresh while existing courses are visible.
  final RxBool isRefreshing = false.obs;

  /// Error shown when there is no usable course data.
  final RxString errorMessage = ''.obs;

  /// Last successful API synchronization time.
  final Rxn<DateTime> lastSyncedAt = Rxn<DateTime>();

  // ===========================================================================
  // CONNECTIVITY
  // ===========================================================================

  bool get isOnline => _connectivity.isOnline.value;

  bool get isOffline => !isOnline;

  bool get hasCourses => courses.isNotEmpty;

  bool _wasOnline = false;

  bool _isFetching = false;

  Worker? _connectivityWorker;

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void onInit() {
    super.onInit();

    _wasOnline = isOnline;

    debugPrint(
      '🏠 HomeController initialized | '
          'Internet: ${isOnline ? 'ONLINE' : 'OFFLINE'}',
    );

    // Listen to connectivity changes.
    _connectivityWorker = ever<bool>(
      _connectivity.isOnline,
      _onConnectivityChanged,
    );

    // Cache first, then network.
    _loadCacheFirst();
  }

  @override
  void onClose() {
    debugPrint('🏠 HomeController disposed');

    _connectivityWorker?.dispose();
    _connectivityWorker = null;

    super.onClose();
  }

  // ===========================================================================
  // INITIAL LOAD
  // ===========================================================================

  Future<void> _loadCacheFirst() async {
    try {
      final cachedCourses = _repository.getCachedCourses();

      lastSyncedAt.value = _repository.lastSyncedAt;

      debugPrint(
        '📦 Initial load | '
            'Online: $isOnline | '
            'Cached courses: ${cachedCourses.length}',
      );

      // -----------------------------------------------------------------------
      // Show cached data immediately.
      // -----------------------------------------------------------------------

      if (cachedCourses.isNotEmpty) {
        courses.assignAll(cachedCourses);

        debugPrint(
          '💾 Showing ${cachedCourses.length} cached courses',
        );

        // If internet is available, silently update cache.
        if (isOnline) {
          await _refreshFromNetwork(silent: true);
        }

        return;
      }

      // -----------------------------------------------------------------------
      // No cache + online.
      // -----------------------------------------------------------------------

      if (isOnline) {
        await _loadInitialFromNetwork();
        return;
      }

      // -----------------------------------------------------------------------
      // No cache + offline.
      // -----------------------------------------------------------------------

      errorMessage.value =
      'No internet connection and no cached courses available.';

      debugPrint('🔴 No cache and device is offline.');
    } catch (e, stackTrace) {
      debugPrint('❌ INITIAL LOAD ERROR: $e');
      debugPrint('$stackTrace');

      if (courses.isEmpty) {
        errorMessage.value = _cleanError(e);
      }
    }
  }

  // ===========================================================================
  // INITIAL NETWORK LOAD
  // ===========================================================================

  Future<void> _loadInitialFromNetwork() async {
    if (!isOnline) {
      errorMessage.value = 'No internet connection.';
      return;
    }

    if (_isFetching) {
      debugPrint('⏳ Initial API request already running.');
      return;
    }

    _isFetching = true;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      debugPrint('🌐 Fetching courses from API...');

      final freshCourses = await _repository.fetchFromApi();

      debugPrint(
        '✅ API returned ${freshCourses.length} courses',
      );

      // Don't replace existing data with an empty response.
      if (freshCourses.isNotEmpty) {
        courses.assignAll(freshCourses);

        lastSyncedAt.value = _repository.lastSyncedAt;

        debugPrint(
          '✅ Courses updated: ${courses.length}',
        );
      } else {
        debugPrint('⚠️ API returned an empty course list.');

        if (courses.isEmpty) {
          errorMessage.value = 'No courses found.';
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ INITIAL API ERROR: $e');
      debugPrint('$stackTrace');

      if (courses.isEmpty) {
        errorMessage.value = _cleanError(e);
      }
    } finally {
      _isFetching = false;
      isLoading.value = false;
    }
  }

  // ===========================================================================
  // CONNECTIVITY CHANGE
  // ===========================================================================

  void _onConnectivityChanged(bool online) {
    debugPrint(
      '📡 Connectivity changed: '
          '${_wasOnline ? 'ONLINE' : 'OFFLINE'} '
          '→ '
          '${online ? 'ONLINE' : 'OFFLINE'}',
    );

    // Save the NEW state immediately.
    final wasOffline = !_wasOnline;

    _wasOnline = online;

    // -------------------------------------------------------------------------
    // INTERNET DISCONNECTED
    // -------------------------------------------------------------------------

    if (!online) {
      debugPrint('🔴 Internet disconnected.');

      // We intentionally don't clear courses.
      // Cached/current courses remain visible.
      return;
    }

    // -------------------------------------------------------------------------
    // INTERNET CONNECTED
    // -------------------------------------------------------------------------

    debugPrint('🟢 Internet is available.');

    // Only refresh when this is an actual OFFLINE → ONLINE transition.
    if (wasOffline) {
      debugPrint('🔄 Internet restored. Refreshing courses...');

      if (!_isFetching) {
        _refreshFromNetwork(
          silent: courses.isNotEmpty,
        );
      }
    }
  }

  // ===========================================================================
  // PULL TO REFRESH
  // ===========================================================================

  Future<void> refresh() async {
    if (!isOnline) {
      debugPrint('🔴 Pull refresh skipped: device is offline.');

      errorMessage.value = 'No internet connection.';
      return;
    }

    await _refreshFromNetwork(
      silent: courses.isNotEmpty,
    );
  }

  // ===========================================================================
  // RETRY
  // ===========================================================================

  Future<void> retry() async {
    errorMessage.value = '';

    if (!isOnline) {
      debugPrint('🔴 Retry skipped: device is offline.');

      errorMessage.value = 'No internet connection.';
      return;
    }

    if (courses.isEmpty) {
      await _loadInitialFromNetwork();
    } else {
      await _refreshFromNetwork(
        silent: true,
      );
    }
  }

  // ===========================================================================
  // NETWORK REFRESH
  // ===========================================================================

  Future<void> _refreshFromNetwork({
    required bool silent,
  }) async {
    if (!isOnline) {
      debugPrint('🔴 Network refresh skipped: device is offline.');
      return;
    }

    if (_isFetching) {
      debugPrint('⏳ Network refresh skipped: request already running.');
      return;
    }

    _isFetching = true;

    if (silent) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    errorMessage.value = '';

    try {
      debugPrint('====================================');
      debugPrint('🌐 FETCHING COURSES FROM NETWORK');
      debugPrint('====================================');

      final freshCourses = await _repository.fetchFromApi();

      debugPrint(
        '📥 Fresh courses received: ${freshCourses.length}',
      );

      // -----------------------------------------------------------------------
      // API returned courses.
      // -----------------------------------------------------------------------

      if (freshCourses.isNotEmpty) {
        courses.assignAll(freshCourses);

        lastSyncedAt.value = _repository.lastSyncedAt;

        debugPrint(
          '✅ Courses updated successfully: ${courses.length}',
        );
      }

      // -----------------------------------------------------------------------
      // API returned empty list.
      // -----------------------------------------------------------------------

      else {
        debugPrint('⚠️ API returned empty course list.');

        // Keep existing cache/current data.
        if (courses.isEmpty) {
          errorMessage.value = 'No courses found.';
        }
      }
    } catch (e, stackTrace) {
      debugPrint('====================================');
      debugPrint('❌ COURSE API ERROR');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('====================================');

      // Keep cached data if available.
      if (courses.isEmpty && isOnline) {
        errorMessage.value = _cleanError(e);
      }
    } finally {
      _isFetching = false;

      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ===========================================================================
  // ERROR HELPER
  // ===========================================================================

  String _cleanError(Object error) {
    final message = error.toString().trim();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length).trim();
    }

    return message;
  }
}