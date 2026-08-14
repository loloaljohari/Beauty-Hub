import 'package:flutter/widgets.dart';

import '../config/app_config.dart';

/// Builds an [ImageProvider] from whatever the backend returned, or
/// `null` when there is nothing usable to load.
///
/// Returning `null` matters: `CircleAvatar.backgroundImage` and
/// `DecorationImage` both accept a nullable provider and fall back to
/// their placeholder, whereas `NetworkImage('')` produces a failed
/// request and a red exception in the console on every rebuild.
///
/// The path is run through [AppConfig.mediaUrl], so relative values
/// like `post_media/x.jpg` resolve against the storage disk and
/// already-absolute URLs are left alone.
ImageProvider? remoteImageProvider(String? path) {
  final url = AppConfig.mediaUrl(path);
  if (url == null) return null;
  return NetworkImage(url);
}

/// Same as [remoteImageProvider] but for the handful of places that
/// need a plain URL string (e.g. `CachedNetworkImage.imageUrl`).
/// Callers must still guard against `null` before using it.
String? remoteImageUrl(String? path) => AppConfig.mediaUrl(path);
