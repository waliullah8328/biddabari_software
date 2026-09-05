import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  /// True when a network connection is available.
  final RxBool isOnline = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  Future<ConnectivityService> init() async {
    debugPrint('📡 ConnectivityService initializing...');

    // Check current connectivity immediately.
    final result = await _connectivity.checkConnectivity();

    _updateStatus(result);

    // Listen for future connectivity changes.
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateStatus,
      onError: (error) {
        debugPrint('❌ Connectivity listener error: $error');
      },
    );

    debugPrint(
      '📡 ConnectivityService initialized | '
          'Online: ${isOnline.value}',
    );

    return this;
  }

  // ---------------------------------------------------------------------------
  // UPDATE STATUS
  // ---------------------------------------------------------------------------

  void _updateStatus(List<ConnectivityResult> results) {
    final online = results.any(
          (result) => result != ConnectivityResult.none,
    );

    debugPrint(
      '📡 Connectivity changed | '
          'Results: $results | '
          'Online: $online',
    );

    // Only update RxBool when the value actually changes.
    if (isOnline.value == online) {
      return;
    }

    isOnline.value = online;

    if (online) {
      debugPrint('🟢 INTERNET CONNECTED');
    } else {
      debugPrint('🔴 INTERNET DISCONNECTED');
    }
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void onClose() {
    debugPrint('📡 ConnectivityService disposed');

    _subscription?.cancel();
    _subscription = null;

    super.onClose();
  }
}