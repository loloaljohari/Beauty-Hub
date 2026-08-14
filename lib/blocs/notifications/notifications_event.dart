import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class NotificationsLoaded extends NotificationsEvent {
  const NotificationsLoaded();
}

class NotificationsTabChanged extends NotificationsEvent {
  const NotificationsTabChanged(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

/// يُستدعى عند فتح صفحة الإشعارات — يصفّر العداد
class NotificationsMarkAsSeen extends NotificationsEvent {
  const NotificationsMarkAsSeen();
}
