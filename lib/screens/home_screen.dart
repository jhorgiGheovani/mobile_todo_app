import 'package:flutter/material.dart';
import 'package:mypersonalapp/widgets/todo_card.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../screens/pomodoro_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/light_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final TaskService _taskService = TaskService();
  List<Todo> _tasks = [];
  bool _isLoading = false;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? selectedTime;
  Priority selectedPriority = Priority.none;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Provider.of<TodoProvider>(context, listen: false).initializeListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getCurrentMonthText(),
                    style: const TextStyle(
                      color: LightTheme.textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz,
                        color: LightTheme.textColor),
                    onPressed: () => _showMoreOptions(context),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: LightTheme.cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                headerVisible: false,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: LightTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  defaultTextStyle: const TextStyle(
                    color: LightTheme.textColor,
                    fontSize: 16,
                  ),
                  weekendTextStyle: const TextStyle(
                    color: LightTheme.textColor,
                    fontSize: 16,
                  ),
                  outsideTextStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                eventLoader: (day) {
                  final todoProvider =
                      Provider.of<TodoProvider>(context, listen: false);
                  final todos = todoProvider.getTodosForDate(day);

                  if (isSameDay(day, DateTime.now())) {
                    return [];
                  }

                  return todos.isNotEmpty ? [const EventDot()] : [];
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 2,
                      ),
                    )
                  : Consumer<TodoProvider>(
                      builder: (context, todoProvider, child) {
                        final todos =
                            todoProvider.getTodosForDate(_selectedDay!);
                        return todos.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: todos.length,
                                itemBuilder: (context, index) {
                                  final todo = todos[index];
                                  return TodoCard(
                                    todo: todo,
                                    onCheckboxChanged: (isChecked) async {
                                      try {
                                        await Provider.of<TodoProvider>(context,
                                                listen: false)
                                            .toggleTodoStatus(todo.id);
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to update task: $e')),
                                          );
                                        }
                                      }
                                    },
                                    onDelete: () async {
                                      try {
                                        await Provider.of<TodoProvider>(context,
                                                listen: false)
                                            .deleteTodo(todo.id);
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to delete task: $e')),
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        backgroundColor: LightTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LightTheme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_today,
              size: 50,
              color: LightTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Tasks Yet!',
            style: TextStyle(
              color: LightTheme.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Looks like you have no tasks scheduled.\nAdd a new task to get started!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LightTheme.textColor.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddTodoDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: LightTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add Task',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard(Todo todo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: LightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(
              color: todo.isCompleted ? Colors.green : Colors.grey[600]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: todo.isCompleted
              ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.green,
                )
              : null,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            color: LightTheme.textColor,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: todo.description.isNotEmpty
            ? Text(
                todo.description,
                style: TextStyle(
                  color: LightTheme.textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (todo.priority != Priority.none)
              Icon(
                Icons.flag,
                color: _getPriorityColor(todo.priority),
                size: 20,
              ),
            const SizedBox(width: 8),
            Text(
              todo.time?.format(context) ?? '',
              style: TextStyle(
                color: LightTheme.textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final FocusNode titleFocusNode = FocusNode();
    DateTime taskDate = _selectedDay!;
    TimeOfDay? selectedTime;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleFocusNode.requestFocus();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LightTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: LightTheme.textColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title and description inputs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      focusNode: titleFocusNode,
                      style: const TextStyle(
                        color: LightTheme.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Task Title',
                        hintStyle: TextStyle(
                          color: LightTheme.textColor.withOpacity(0.7),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      style: TextStyle(
                        color: LightTheme.textColor.withOpacity(0.7),
                        fontSize: 17,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add details',
                        hintStyle: TextStyle(
                          color: LightTheme.textColor.withOpacity(0.7),
                          fontSize: 17,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Action buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: LightTheme.cardColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Date and time row
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.calendar_today,
                          label: _getDateText(taskDate),
                          onTap: () {
                            _showDatePicker(
                              context,
                              taskDate,
                              (newDate) {
                                setState(() {
                                  taskDate = newDate;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.access_time,
                          label: selectedTime?.format(context) ?? 'Add time',
                          onTap: () {
                            _showTimePicker(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Priority and category row
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.flag_outlined,
                          label: 'Priority',
                          color: _getPriorityColor(selectedPriority),
                          onTap: () {
                            _showPriorityPicker(context, (priority) {
                              setState(() {
                                selectedPriority = priority;
                              });
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.folder_outlined,
                          label: 'Category',
                          onTap: () {
                            // Category picker logic
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Add button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            final todo = Todo(
                              id: DateTime.now().toString(),
                              title: titleController.text,
                              description: descriptionController.text,
                              date: taskDate,
                              time: selectedTime,
                              priority: selectedPriority,
                            );
                            try {
                              Provider.of<TodoProvider>(context, listen: false)
                                  .addTodo(todo);
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to create task: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: LightTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color ?? Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color ?? Colors.blue,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateText(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return '${date.day} ${_getMonthName(date.month)}';
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  String _getCurrentMonthText() {
    final now = DateTime.now();
    if (isSameDay(_selectedDay, now)) {
      return '${_getMonthName(_selectedDay!.month).substring(0, 3)}, Today';
    } else {
      return '${_getMonthName(_selectedDay!.month).substring(0, 3)}, ${_selectedDay!.year}';
    }
  }

  void _showDatePicker(BuildContext context, DateTime currentDate,
      Function(DateTime) onDateSelected) {
    DateTime selectedDate = currentDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: LightTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: LightTheme.textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Date',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Duration',
                              style: TextStyle(
                                color: LightTheme.textColor.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.white),
                        onPressed: () {
                          onDateSelected(selectedDate);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime(2025, 12, 31),
                  focusedDay: selectedDate,
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      selectedDate = selected;
                    });
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Colors.white),
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: const TextStyle(color: Colors.white),
                    outsideTextStyle: TextStyle(color: Colors.grey[600]),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.grey),
                  title: const Text(
                    'Time',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    _getTimeText(selectedTime),
                    style: TextStyle(
                      color:
                          selectedTime != null ? Colors.blue : Colors.grey[600],
                    ),
                  ),
                  onTap: () => _showTimePicker(context),
                ),
                ListTile(
                  leading:
                      const Icon(Icons.notifications_none, color: Colors.grey),
                  title: const Text(
                    'Reminder',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    'None',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.repeat, color: Colors.grey),
                  title: const Text(
                    'Repeat',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    'None',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {},
                ),
                TextButton(
                  onPressed: () {
                    selectedDate = DateTime.now();
                  },
                  child: const Text(
                    'CLEAR',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeText(TimeOfDay? time) {
    if (time == null) return 'None';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: LightTheme.cardColor,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              dayPeriodColor: Colors.blue.withOpacity(0.2),
              dayPeriodTextColor: Colors.blue,
              hourMinuteColor: Colors.blue.withOpacity(0.2),
              hourMinuteTextColor: Colors.white,
              dialHandColor: Colors.blue,
              dialBackgroundColor: Colors.grey[900],
              hourMinuteTextStyle: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              dayPeriodTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              helpTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _showPriorityPicker(
      BuildContext context, Function(Priority) onPrioritySelected) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: LightTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.red),
              title: const Text(
                'High Priority',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                onPrioritySelected(Priority.high);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.orange),
              title: const Text(
                'Medium Priority',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                onPrioritySelected(Priority.medium);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.blue),
              title: const Text(
                'Low Priority',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                onPrioritySelected(Priority.low);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.grey),
              title: const Text(
                'No Priority',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                onPrioritySelected(Priority.none);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.blue;
      case Priority.none:
        return Colors.grey;
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LightTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.timer_outlined, color: LightTheme.textColor),
              title: const Text(
                'Pomodoro Timer',
                style: TextStyle(
                  color: LightTheme.textColor,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PomodoroScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.person_outline, color: LightTheme.textColor),
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: LightTheme.textColor,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EventDot {
  const EventDot();
}
