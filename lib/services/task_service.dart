// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../models/todo.dart';

// class TaskService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   //local
//   final String _baseUrl = 'http://10.0.2.2:5001/clockin-6c38c/us-central1';

//   // Create a new task
//   Future<String> createTask({
//     required String title,
//     required String description,
//     required DateTime date,
//     required TimeOfDay? time,
//     Priority priority = Priority.none,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/createTask'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'data': {
//             'title': title,
//             'description': description,
//             'date': date.toIso8601String(),
//             'time': time != null
//                 ? {
//                     'hour': time.hour,
//                     'minute': time.minute,
//                   }
//                 : null,
//             'priority': priority.toString(),
//           }
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final result = data['result'] as Map<String, dynamic>;
//         if (result['success'] == true && result['id'] != null) {
//           return result['id'];
//         }
//       }
//       throw Exception('Failed to create task: ${response.body}');
//     } catch (e) {
//       throw Exception('Failed to create task: $e');
//     }
//   }

//   // Get all tasks
//   Future<List<Todo>> getTasks() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) throw Exception('User not authenticated');

//       final response = await http
//           .get(
//         Uri.parse('$_baseUrl/getTasks?uid=${user.uid}'),
//       )
//           .timeout(
//         const Duration(seconds: 5),
//         onTimeout: () {
//           throw Exception(
//               'Connection timeout. Make sure Firebase emulator is running.');
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final tasksList = data['tasks'] as List;

//         return tasksList.map((taskData) {
//           final timeMap = taskData['time'] as Map<String, dynamic>?;
//           DateTime date;

//           if (taskData['date'] is Map && taskData['date']['_seconds'] != null) {
//             // Handle Firestore timestamp format
//             final seconds = taskData['date']['_seconds'] as int;
//             date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
//           } else if (taskData['date'] is String) {
//             // Handle ISO string format
//             date = DateTime.parse(taskData['date']);
//           } else {
//             throw Exception('Invalid date format');
//           }

//           return Todo(
//             id: taskData['id'],
//             title: taskData['title'] ?? '',
//             description: taskData['description'] ?? '',
//             date: date,
//             time: timeMap != null
//                 ? TimeOfDay(
//                     hour: timeMap['hour'],
//                     minute: timeMap['minute'],
//                   )
//                 : null,
//             priority: Priority.values.firstWhere(
//               (e) => e.toString() == taskData['priority'],
//               orElse: () => Priority.none,
//             ),
//             isCompleted: taskData['isCompleted'] ?? false,
//           );
//         }).toList();
//       } else {
//         throw Exception(
//             'Failed to load tasks: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Failed to get tasks: $e');
//     }
//   }

//   // Update a task
//   Future<void> updateTask({
//     required String taskId,
//     required String title,
//     required String description,
//     required DateTime date,
//     required TimeOfDay? time,
//     required Priority priority,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/updateTask'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'data': {
//             'taskId': taskId,
//             'title': title,
//             'description': description,
//             'date': date.toIso8601String(),
//             'time': time != null
//                 ? {
//                     'hour': time.hour,
//                     'minute': time.minute,
//                   }
//                 : null,
//             'priority': priority.toString(),
//           }
//         }),
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Failed to update task: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Failed to update task: $e');
//     }
//   }

//   // Delete a task
//   Future<void> deleteTask(String taskId) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/deleteTask'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'data': {
//             'taskId': taskId,
//           }
//         }),
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Failed to delete task: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Failed to delete task: $e');
//     }
//   }

//   // Toggle task completion status
//   Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/updateTask'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'data': {
//             'taskId': taskId,
//             'isCompleted': !currentStatus,
//           }
//         }),
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Failed to toggle task status: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Failed to toggle task status: $e');
//     }
//   }
// }
