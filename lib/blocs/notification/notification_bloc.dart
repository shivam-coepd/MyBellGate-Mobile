import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/repositories/notification_repository.dart';
import 'package:mygate_coepd/models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc({required NotificationRepository repository})
      : _repository = repository,
        super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onLoadNotifications(
      LoadNotifications event, Emitter<NotificationState> emit) async {
    try {
      final currentState = state;
      int page = 1;
      List<NotificationModel> existingNotifications = [];

      if (event.refresh) {
        emit(NotificationLoading());
      } else if (currentState is NotificationLoaded) {
        if (!currentState.hasMore) return;
        page = currentState.page + 1;
        existingNotifications = currentState.notifications;
        emit(currentState.copyWith(isPaginating: true));
      } else {
        emit(NotificationLoading());
      }

      final result = await _repository.getNotifications(page: page);
      
      final newNotifications = result['notifications'] as List<NotificationModel>;
      final hasMore = result['has_more'] as bool;
      final unreadCount = result['unread_count'] as int;

      emit(NotificationLoaded(
        notifications: [...existingNotifications, ...newNotifications],
        unreadCount: unreadCount,
        hasMore: hasMore,
        page: page,
      ));
    } catch (e) {
      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        emit(current.copyWith(isPaginating: false));
      } else {
        emit(NotificationError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onMarkAsRead(
      MarkAsRead event, Emitter<NotificationState> emit) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    try {
      // Optimistic update
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == event.id) {
          return NotificationModel(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            referenceId: n.referenceId,
            actionUrl: n.actionUrl,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      final newUnreadCount = (currentState.unreadCount - 1).clamp(0, 999);

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));

      await _repository.markAsRead(event.id);
    } catch (e) {
      // Revert optimism if needed (simple approach: just print error here)
    }
  }

  Future<void> _onMarkAllAsRead(
      MarkAllAsRead event, Emitter<NotificationState> emit) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    try {
      // Optimistic update
      final updatedNotifications = currentState.notifications.map((n) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          referenceId: n.referenceId,
          actionUrl: n.actionUrl,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      ));

      await _repository.markAllAsRead();
    } catch (e) {
      //
    }
  }
}
