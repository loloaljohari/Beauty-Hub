import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/material_item_model.dart';
import '../../data/repositories/material_inventory_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc
    extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    MaterialInventoryRepository? repository,
    NotificationsRepository? notificationsRepository,
  })  : _repository = repository ?? const MaterialInventoryRepository(),
        _notifications =
            notificationsRepository ?? const NotificationsRepository(),
        super(const NotificationsState()) {
    on<NotificationsLoaded>(_onLoaded);
    on<NotificationsTabChanged>(_onTabChanged);
    on<NotificationsMarkAsSeen>(_onMarkAsSeen);
  }

  final MaterialInventoryRepository _repository;
  final NotificationsRepository _notifications;
  Future<void> _onLoaded(
    NotificationsLoaded event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final result = await _repository.getInventoryAlerts();

      // Real notifications come from the role-agnostic
      // `/api/notifications`. A 404 means the route is not deployed
      // yet, and the stock alerts tab should still work.
      var items = state.notifications;
      var unread = state.unreadCount;

      try {
        final bundle = await _notifications.getNotifications();
        items = bundle.items;
        unread = bundle.unreadCount;
      } on ApiException catch (e) {
        if (!e.isNotFound) rethrow;
      } catch (_) {}

      emit(state.copyWith(
        alertItems: result['items'] as List<MaterialItemModel>,
        alertCount: result['count'] as int,
        notifications: items,
        unreadCount: unread,
        status: NotificationsStatus.loaded,
        hasSeen: false,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onTabChanged(
    NotificationsTabChanged event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(tabIndex: event.index));
  }

  /// Marks everything read server-side too, so the badge does not come
  /// back on the next cold open.
  Future<void> _onMarkAsSeen(
    NotificationsMarkAsSeen event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(hasSeen: true, unreadCount: 0));

    try {
      await _notifications.markAllRead();
    } catch (_) {
      // A failed read-receipt is not worth surfacing.
    }
  }
}