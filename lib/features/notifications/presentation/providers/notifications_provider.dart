import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/providers/supabase_provider.dart';
import '../../../../core/services/app_notification_dispatcher.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NotificationsState {
  final List<Map<String, dynamic>> myNotifications;
  final List<Map<String, dynamic>> employees;
  final bool isLoading;
  final bool isSending;
  final int unreadCount;
  final String? error;

  const NotificationsState({
    this.myNotifications = const [],
    this.employees = const [],
    this.isLoading = false,
    this.isSending = false,
    this.unreadCount = 0,
    this.error,
  });

  NotificationsState copyWith({
    List<Map<String, dynamic>>? myNotifications,
    List<Map<String, dynamic>>? employees,
    bool? isLoading,
    bool? isSending,
    int? unreadCount,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      myNotifications: myNotifications ?? this.myNotifications,
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      unreadCount: unreadCount ?? this.unreadCount,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  late SupabaseClient _client;


  Future<void> loadUnreadCount() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final rows = await _client
          .from('app_notifications')
          .select('id')
          .eq('recipient_id', userId)
          .eq('is_read', false);

      state = state.copyWith(unreadCount: rows.length);
    } catch (_) {}
  }
  @override
  NotificationsState build() {
    _client = ref.read(supabaseClientProvider);
    ref.watch(sessionVersionProvider);
    return const NotificationsState();
  }

  String? get _currentUserId => ref.read(authProvider).user?.id;

  Future<void> bootstrapForCurrentUser() async {
    await loadMyNotifications();
    await loadUnreadCount();
  }

  Future<void> loadMyNotifications() async {
    final userId = _currentUserId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final rows = await _client
          .from('app_notifications')
          .select()
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(200);

      final list = rows.map((e) => Map<String, dynamic>.from(e)).toList();
      final unread = list.where((e) => e['is_read'] != true).length;

      state = state.copyWith(
        myNotifications: list,
        unreadCount: unread,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('app_notifications')
        .update({
      'is_read': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    })
        .eq('id', notificationId);

    await loadMyNotifications();
  }

  Future<void> markAllAsRead() async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _client
        .from('app_notifications')
        .update({
      'is_read': true,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    })
        .eq('recipient_id', userId)
        .eq('is_read', false);

    await loadMyNotifications();
  }

  Future<void> loadEmployees() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rows = await _client
          .from('profiles')
          .select('id, full_name, email')
          .eq('role', 'employee')
          .eq('is_active', true)
          .order('full_name', ascending: true);

      state = state.copyWith(
        employees: rows.map((e) => Map<String, dynamic>.from(e)).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> sendAnnouncement({
    required String title,
    required String body,
    String? targetEmployeeId,
  }) async {
    final senderId = _currentUserId;
    if (senderId == null) return false;

    state = state.copyWith(isSending: true, clearError: true);

    try {
      List<String> recipientIds;

      if (targetEmployeeId != null && targetEmployeeId.trim().isNotEmpty) {
        recipientIds = [targetEmployeeId];
      } else {
        final rows = await _client
            .from('profiles')
            .select('id')
            .eq('role', 'employee')
            .eq('is_active', true);

        recipientIds = rows.map<String>((e) => e['id'].toString()).toList();
      }

      await AppNotificationDispatcher.instance.notifyManyEmployees(
        client: _client,
        recipientIds: recipientIds,
        senderId: senderId,
        title: title,
        body: body,
        kind: 'announcement',
        payload: {
          'target': targetEmployeeId == null ? 'all_employees' : 'single_employee',
        },
      );

      state = state.copyWith(isSending: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
      return false;
    }
  }
}

final notificationsProvider =
NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);