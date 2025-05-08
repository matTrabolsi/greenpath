import 'package:flutter/material.dart';

class Reminder {
  final int id; // Unique ID for the notification
  final String title;
  final TimeOfDay time;
  final List<int> repeatDays; // 1=Monday, ..., 7=Sunday
  final bool isDaily;

  const Reminder({
    required this.id,
    required this.title,
    required this.time,
    this.repeatDays = const [],
    this.isDaily = false,
  });

  // Convert Reminder to a Map (for JSON storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'hour': time.hour,
      'minute': time.minute,
      'repeatDays': repeatDays,
      'isDaily': isDaily,
    };
  }

  // Create a Reminder from a Map (JSON)
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      time: TimeOfDay(hour: map['hour'], minute: map['minute']),
      repeatDays: List<int>.from(map['repeatDays']),
      isDaily: map['isDaily'],
    );
  }
}
