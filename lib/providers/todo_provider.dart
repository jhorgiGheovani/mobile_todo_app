import 'dart:async';

import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Todo> _todos = [];
  StreamSubscription<QuerySnapshot>? _todosSubscription;

  List<Todo> get todos => _todos;

  List<Todo> getTodosForDate(DateTime date) {
    return _todos
        .where((todo) =>
            todo.date.year == date.year &&
            todo.date.month == date.month &&
            todo.date.day == date.day)
        .toList();
  }

  void initializeListener() {
    _todosSubscription?.cancel();
    _todosSubscription = _firestoreService.tasksStream.listen(
      (snapshot) {
        _todos = snapshot.docs.map((doc) {
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
        notifyListeners();
      },
      onError: (error) {
        print('Error in todos stream: $error');
      },
    );
  }

  @override
  void dispose() {
    _todosSubscription?.cancel();
    super.dispose();
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final id = await _firestoreService.createTask(
        title: todo.title,
        description: todo.description,
        date: todo.date,
        time: todo.time,
        priority: todo.priority,
      );

      final newTodo = todo.copyWith(id: id);
      _todos.add(newTodo);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadTodos() async {
    try {
      _todos = await _firestoreService.getTasks();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _firestoreService.deleteTask(id);
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleTodoStatus(String id) async {
    try {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        final currentStatus = _todos[index].isCompleted;

        await _firestoreService.toggleTaskStatus(id, currentStatus);

        _todos[index] = _todos[index].copyWith(isCompleted: !currentStatus);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTodo(
    String id,
    String title,
    String description,
    DateTime date,
    TimeOfDay? time,
    Priority priority,
  ) async {
    try {
      await _firestoreService.updateTask(
        taskId: id,
        title: title,
        description: description,
        date: date,
        time: time,
        priority: priority,
      );

      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(
          title: title,
          description: description,
          date: date,
          time: time,
          priority: priority,
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
