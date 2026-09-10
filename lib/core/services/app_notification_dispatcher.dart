import 'package:supabase_flutter/supabase_flutter.dart';

class AppNotificationDispatcher {
  AppNotificationDispatcher._();
  static final AppNotificationDispatcher instance =
  AppNotificationDispatcher._();

  Future<void> notifyAdmins({
    required SupabaseClient client,
    required String title,
    required String body,
    required String senderId,
    String kind = 'general',
    Map<String, dynamic> payload = const {},
  }) async {
    await client.rpc(
      'create_notifications_for_admins',
      params: {
        'p_sender_id': senderId,
        'p_title': title,
        'p_body': body,
        'p_kind': kind,
        'p_payload': payload,
      },
    );
  }

  Future<void> notifyEmployee({
    required SupabaseClient client,
    required String recipientId,
    required String senderId,
    required String title,
    required String body,
    String kind = 'general',
    Map<String, dynamic> payload = const {},
  }) async {
    await _insertMany(
      client: client,
      recipientIds: [recipientId],
      senderId: senderId,
      title: title,
      body: body,
      kind: kind,
      payload: payload,
    );
  }

  Future<void> notifyManyEmployees({
    required SupabaseClient client,
    required List<String> recipientIds,
    required String senderId,
    required String title,
    required String body,
    String kind = 'announcement',
    Map<String, dynamic> payload = const {},
  }) async {
    if (recipientIds.isEmpty) return;
    await _insertMany(
      client: client,
      recipientIds: recipientIds,
      senderId: senderId,
      title: title,
      body: body,
      kind: kind,
      payload: payload,
    );
  }

  Future<void> _insertMany({
    required SupabaseClient client,
    required List<String> recipientIds,
    required String senderId,
    required String title,
    required String body,
    required String kind,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final rows = recipientIds
        .map(
          (id) => <String, dynamic>{
        'recipient_id': id,
        'sender_id': senderId,
        'title': title,
        'body': body,
        'kind': kind,
        'payload': payload,
        'is_read': false,
        'created_at': now,
        'updated_at': now,
      },
    )
        .toList();

    await client.from('app_notifications').insert(rows);
  }
}