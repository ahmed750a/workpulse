import 'package:flutter/material.dart';

String formatTime12(String? value) {
  if (value == null || value.trim().isEmpty) return '--';

  try {
    final parts = value.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final suffix = hour < 12 ? 'ص' : 'م';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    return '$hour12:${minute.toString().padLeft(2, '0')} $suffix';
  } catch (_) {
    return value;
  }
}

String formatDateTimeToTime12(String? value) {
  if (value == null || value.trim().isEmpty) return '--';

  try {
    final date = DateTime.parse(value).toLocal();
    final suffix = date.hour < 12 ? 'ص' : 'م';
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour12:$minute $suffix';
  } catch (_) {
    return value;
  }
}

String formatTimeOfDay12(TimeOfDay time) {
  final suffix = time.hour < 12 ? 'ص' : 'م';
  final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');

  return '$hour12:$minute $suffix';
}