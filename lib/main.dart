import 'package:beautyhup/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/localization/localized_app.dart';
import 'core/network/api_client.dart';
import 'core/notification/device_token_sync.dart';
import 'core/notification/initializeNotification.dart';
import 'core/storage/storage_service.dart';
import 'data/repositories/service_categories_repository.dart';

/// App entry point.
///
/// Order matters here:
///   1. SharedPreferences is opened once, so later reads are cheap and
///      never race with the first API call.
///   2. The saved session token is loaded into [ApiClient] BEFORE any
///      widget builds, so the first authenticated request already
///      carries the header.
///   3. A global 401 handler is installed, so an expired or revoked
///      token sends the user back to login from anywhere in the app
///      instead of leaving screens stuck on a spinner.
///
/// Firebase setup is untouched - it initialises exactly as before.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await StorageService.init();
  await ApiClient.restoreSession();

  // Last known category list first (instant), then refresh in the
  // background so the screens are never blocked on it.
  await ServiceCategoriesRepository.restore();
  ServiceCategoriesRepository.refresh();

  await initializeNotifications();

  // Now that the session is restored, hand the FCM token to the backend.
  // Fire-and-forget: push registration must not delay first paint.
  DeviceTokenSync.start();

  final isLoggedIn = await StorageService.isLoggedIn();
 await StorageService. getLocale();
  runApp(BeautyHubApp(isLoggedIn: isLoggedIn));
}

/// Wraps [LocalizedApp] with a navigator key so non-widget code (the
/// API client's 401 handler) can still navigate.
class BeautyHubApp extends StatefulWidget {
  const BeautyHubApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  State<BeautyHubApp> createState() => _BeautyHubAppState();
}

class _BeautyHubAppState extends State<BeautyHubApp> {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  bool _redirecting = false;

  @override
  void initState() {
    super.initState();

    ApiClient.onUnauthorized = () async {
      // The client already dropped the token; clear the rest of the
      // session and bounce to login. Guarded so several in-flight
      // requests failing at once cannot stack multiple redirects.
      if (_redirecting) return;
      _redirecting = true;

      await StorageService.clearUserData();

      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        navigator.pushNamedAndRemoveUntil('/login', (route) => false);
      }

      _redirecting = false;
    };
  }

  @override
  void dispose() {
    ApiClient.onUnauthorized = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocalizedApp(
      isLoggedIn: widget.isLoggedIn,
      navigatorKey: navigatorKey,
    );
  }
}
