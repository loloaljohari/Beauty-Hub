import 'package:equatable/equatable.dart';
import '../../data/models/material_item_model.dart';
import '../../data/repositories/notifications_repository.dart';

enum NotificationsStatus { initial, loading, loaded, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.alertItems = const [],
    this.alertCount = 0,
    this.tabIndex = 0,
    this.status = NotificationsStatus.initial,
    this.errorMessage,
    this.hasSeen = false,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  final List<MaterialItemModel> alertItems;
  final int alertCount;
  final int tabIndex;
  final NotificationsStatus status;
  final String? errorMessage;

  /// false = يوجد إشعارات لم يرها المستخدم → تظهر النقطة الحمراء
  final bool hasSeen;

  /// Real notifications from `/api/notifications`, separate from the
  /// locally derived stock alerts.
  final List<AppNotification> notifications;
  final int unreadCount;

  bool get showBadge => (alertCount > 0 || unreadCount > 0) && !hasSeen;

  NotificationsState copyWith({
    List<MaterialItemModel>? alertItems,
    int? alertCount,
    int? tabIndex,
    List<AppNotification>? notifications,
    int? unreadCount,
    NotificationsStatus? status,
    String? errorMessage,
    bool? hasSeen,
  }) {
    return NotificationsState(
      alertItems: alertItems ?? this.alertItems,
      alertCount: alertCount ?? this.alertCount,
      tabIndex: tabIndex ?? this.tabIndex,
      status: status ?? this.status,
      errorMessage: errorMessage,
      hasSeen: hasSeen ?? this.hasSeen,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        alertItems, alertCount, tabIndex,
        status, errorMessage, hasSeen,
        notifications, unreadCount,
      ];
}
