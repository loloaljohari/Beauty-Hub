import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../storage/storage_service.dart';

/// Registers this device's FCM token with the backend so the server can
/// push booking, chat, and employment notifications to it.
///
/// The backend exposes `POST /expert/device-token` for exactly this and
/// expects to be called once when Firebase issues a token and again on
/// every `onTokenRefresh`. Before this existed the app printed the FCM
/// token to the console and never sent it anywhere, so no push could
/// ever reach the device.
class DeviceTokenSync {
  DeviceTokenSync._();

  /// Guards against subscribing to `onTokenRefresh` twice, since
  /// [start] is called both from `main()` and right after a login.
  static StreamSubscription<String>? _refreshSubscription;

  /// Sends the current token, then keeps listening for refreshes.
  ///
  /// Safe to call repeatedly: the last synced value is remembered
  /// locally, so an unchanged token is not re-sent, and the refresh
  /// listener is only attached once. Every failure is swallowed - push
  /// registration must never block the app or show the user an error
  /// they cannot act on.
  static Future<void> start() async {
    if (!await StorageService.isLoggedIn()) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      // Forced: on a fresh login the stored "already synced" value may
      // belong to the PREVIOUS account on this device, so skipping the
      // send would leave the new account unreachable by push.
      await _register(token, force: true);
    } catch (e) {
      if (kDebugMode) debugPrint('[fcm] initial sync failed: $e');
    }

    _refreshSubscription ??=
        FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      try {
        await _register(token, force: true);
      } catch (e) {
        if (kDebugMode) debugPrint('[fcm] refresh sync failed: $e');
      }
    });
  }

  static Future<void> _register(String? token, {bool force = false}) async {
    if (token == null || token.isEmpty) return;
    if (!ApiClient.hasToken) return;

    if (!force && await StorageService.getSyncedDeviceToken() == token) {
      return;
    }

    await ApiClient.post(
      ApiEndpoints.deviceToken,
      body: {
        'device_token': token,
        'platform': defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
      },
    );

    await StorageService.saveSyncedDeviceToken(token);
  }

  /// Unregisters on logout so the account stops receiving pushes on a
  /// device someone else may now be using.
  ///
  /// Must run BEFORE the token is cleared, since the call itself needs
  /// the session header.
  static Future<void> stop() async {
    try {
      final token = await StorageService.getSyncedDeviceToken();
      if (token == null || token.isEmpty) return;

      await ApiClient.delete(
        ApiEndpoints.deviceToken,
        body: {'device_token': token},
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[fcm] unregister failed: $e');
    } finally {
      // Drop the listener too: the next login re-attaches it, and
      // leaving it live would push the next account's token under the
      // old session.
      await _refreshSubscription?.cancel();
      _refreshSubscription = null;
    }
  }
}
