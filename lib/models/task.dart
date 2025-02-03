import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String uid;
  final String title;
  final String subtitle;
  final String time;
  final String category;
  final bool isCompleted;
  final DateTime date;

  Task({
    required this.id,
    required this.uid,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.category,
    this.isCompleted = false,
    required this.date,
  });

  // Create a Task from Firestore document
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      uid: data['uid'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      time: data['time'] ?? '',
      category: data['category'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Convert Task to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'category': category,
      'isCompleted': isCompleted,
      'date': Timestamp.fromDate(date),
    };
  }

  // Create a copy of Task with modified fields
  Task copyWith({
    String? id,
    String? uid,
    String? title,
    String? subtitle,
    String? time,
    String? category,
    bool? isCompleted,
    DateTime? date,
  }) {
    return Task(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
    );
  }
}
