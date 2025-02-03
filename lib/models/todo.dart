import 'package:flutter/material.dart';

enum Priority {
  none,
  low,
  medium,
  high,
}

class Todo {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay? time;
  final Priority priority;
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.time,
    this.priority = Priority.none,
    this.isCompleted = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    Priority? priority,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
