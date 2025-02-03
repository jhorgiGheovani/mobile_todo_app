import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/todo.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _getTasksCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore.collection('tasks');
  }

  // Get a single task by ID
  Future<Todo?> getTaskById(String taskId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tasksCollection = _getTasksCollection();
      final docSnapshot = await tasksCollection.doc(taskId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data() as Map<String, dynamic>;

      // Verify the task belongs to the current user
      if (data['uid'] != user.uid) {
        throw Exception('Not authorized to access this task');
      }

      final timeMap = data['time'] as Map<String, dynamic>?;

      return Todo(
        id: docSnapshot.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        date: DateTime.parse(data['date']),
        time: timeMap != null
            ? TimeOfDay(
                hour: timeMap['hour'],
                minute: timeMap['minute'],
              )
            : null,
        priority: Priority.values.firstWhere(
          (e) => e.toString() == data['priority'],
          orElse: () => Priority.none,
        ),
        isCompleted: data['isCompleted'] ?? false,
      );
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  // Create a new task
  Future<String> createTask({
    required String title,
    required String description,
    required DateTime date,
    required TimeOfDay? time,
    Priority priority = Priority.none,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tasksCollection = _getTasksCollection();
      final docRef = await tasksCollection.add({
        'uid': user.uid,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'time': time != null
            ? {
                'hour': time.hour,
                'minute': time.minute,
              }
            : null,
        'priority': priority.toString(),
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Get all tasks for current user
  Future<List<Todo>> getTasks() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tasksCollection = _getTasksCollection();
      final snapshot = await tasksCollection
          .where('uid', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timeMap = data['time'] as Map<String, dynamic>?;

        return Todo(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: DateTime.parse(data['date']),
          time: timeMap != null
              ? TimeOfDay(
                  hour: timeMap['hour'],
                  minute: timeMap['minute'],
                )
              : null,
          priority: Priority.values.firstWhere(
            (e) => e.toString() == data['priority'],
            orElse: () => Priority.none,
          ),
          isCompleted: data['isCompleted'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  // Update a task
  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required DateTime date,
    required TimeOfDay? time,
    required Priority priority,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tasksCollection = _getTasksCollection();
      await tasksCollection.doc(taskId).update({
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'time': time != null
            ? {
                'hour': time.hour,
                'minute': time.minute,
              }
            : null,
        'priority': priority.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tasksCollection = _getTasksCollection();

      // Verify the task belongs to the current user before deleting
      final taskDoc = await tasksCollection.doc(taskId).get();
      final data = taskDoc.data() as Map<String, dynamic>;

      if (data['uid'] != user.uid) {
        throw Exception('Not authorized to delete this task');
      }

      await tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tasksCollection = _getTasksCollection();

      // Verify the task belongs to the current user before updating
      final taskDoc = await tasksCollection.doc(taskId).get();
      final data = taskDoc.data() as Map<String, dynamic>;

      if (data['uid'] != user.uid) {
        throw Exception('Not authorized to update this task');
      }

      await tasksCollection.doc(taskId).update({
        'isCompleted': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to toggle task status: $e');
    }
  }

  // Get tasks for a specific date
  Future<List<Todo>> getTasksForDate(DateTime date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final tasksCollection = _getTasksCollection();
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await tasksCollection
          .where('uid', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timeMap = data['time'] as Map<String, dynamic>?;

        return Todo(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: DateTime.parse(data['date']),
          time: timeMap != null
              ? TimeOfDay(
                  hour: timeMap['hour'],
                  minute: timeMap['minute'],
                )
              : null,
          priority: Priority.values.firstWhere(
            (e) => e.toString() == data['priority'],
            orElse: () => Priority.none,
          ),
          isCompleted: data['isCompleted'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get tasks for date: $e');
    }
  }

  // Add this getter for real-time updates
  Stream<QuerySnapshot> get tasksStream {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('tasks')
        .where('uid', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
