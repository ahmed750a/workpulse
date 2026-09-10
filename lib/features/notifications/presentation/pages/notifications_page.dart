import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(notificationsProvider.notifier).loadMyNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'الإشعارات',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: () => ref.read(notificationsProvider.notifier).loadMyNotifications(),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F172A)),
          ),
          IconButton(
            tooltip: 'تحديد الكل كمقروء',
            onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
            icon: const Icon(Icons.done_all_rounded, color: Color(0xFF0F172A)),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.myNotifications.isEmpty
          ? const Center(
        child: Text(
          'لا توجد إشعارات حالياً',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
        itemCount: state.myNotifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = state.myNotifications[index];
          final isRead = item['is_read'] == true;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isRead
                ? null
                : () => ref
                .read(notificationsProvider.notifier)
                .markAsRead(item['id'].toString()),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isRead ? const Color(0xFFE2E8F0) : const Color(0xFF99F6E4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isRead
                        ? Icons.notifications_none_rounded
                        : Icons.notifications_active_rounded,
                    color: isRead ? const Color(0xFF94A3B8) : const Color(0xFF0F766E),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['body']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}