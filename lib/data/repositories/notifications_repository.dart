import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';

/// Real notifications, from the role-agnostic `/api/notifications`.
///
/// The `notifications` table always supported every account type
/// (`recipient_type` covers user / expert / salon / beauty_center /
/// admin), but no route read it - so the app was showing pending
/// employment requests in the notifications slot instead.
///
/// These paths start with `/` deliberately: that escapes the `/expert`
/// prefix, because one controller serves all roles and the recipient
/// comes from the token rather than the URL.
class NotificationsRepository {
  const NotificationsRepository();

  /// GET /api/notifications -> data.notifications + data.unread_count
  Future<NotificationsBundle> getNotifications({
    bool unreadOnly = false,
    String? type,
    int limit = 50,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.notifications,
      query: {
        if (unreadOnly) 'unread': 1,
        if (type != null && type.isNotEmpty) 'type': type,
        'limit': limit,
      },
    );

    final payload = ApiResponse.data(response);

    return NotificationsBundle(
      unreadCount: ApiResponse.asInt(payload['unread_count']),
      items: ApiResponse.asMapList(payload['notifications'])
          .map((row) => AppNotification(
                id: ApiResponse.asString(row['id']),
                type: ApiResponse.asString(row['type']),
                title: ApiResponse.asString(row['title']),
                body: ApiResponse.asString(row['body']),
                isRead: ApiResponse.asBool(row['is_read']),
                createdAt: ApiResponse.asString(row['created_at']),
                data: ApiResponse.asMap(row['data']),
              ))
          .toList(),
    );
  }

  /// GET /api/notifications/unread-count — for the badge alone, without
  /// pulling the whole list.
  Future<int> getUnreadCount() async {
    final response =
        await ApiClient.get(ApiEndpoints.notificationsUnreadCount);

    return ApiResponse.asInt(ApiResponse.data(response)['unread_count']);
  }

  Future<void> markRead(Object id) async {
    await ApiClient.post(ApiEndpoints.readNotification(id));
  }

  Future<void> markAllRead() async {
    await ApiClient.post(ApiEndpoints.notificationsReadAll);
  }

  Future<void> delete(Object id) async {
    await ApiClient.delete(ApiEndpoints.deleteNotification(id));
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    this.createdAt = '',
    this.data = const {},
  });

  final String id;

  /// The server's enum: booking_confirmed, employment_request,
  /// stock_alert, and so on. Drives which icon the row shows.
  final String type;

  final String title;
  final String body;
  final bool isRead;
  final String createdAt;

  /// Free-form payload the sender attached, e.g. the booking id to open.
  final Map<String, dynamic> data;
}

class NotificationsBundle {
  const NotificationsBundle({this.items = const [], this.unreadCount = 0});

  final List<AppNotification> items;
  final int unreadCount;

  bool get isEmpty => items.isEmpty;
}
