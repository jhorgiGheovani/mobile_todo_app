import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mypersonalapp/widgets/create_task_bottom_sheet.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime _selectedDate = DateTime.now();

  // Add these variables for calendar
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String? get _userId => _auth.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedDate = _focusedDay;
  }

  Future<void> _createTask(Task task) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      final taskWithUser = task.copyWith(uid: _userId);
      await _firestore.collection('tasks').add(taskWithUser.toMap());
    } catch (e) {
      print('Error creating task: $e');
    }
  }

  Future<void> _updateTask(Task task) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (task.uid != _userId)
        throw Exception('Not authorized to update this task');
      await _firestore.collection('tasks').doc(task.id).update(task.toMap());
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      final task = Task.fromFirestore(doc);
      if (task.uid != _userId)
        throw Exception('Not authorized to delete this task');
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      if (task.uid != _userId)
        throw Exception('Not authorized to update this task');
      await _firestore.collection('tasks').doc(task.id).update({
        'isCompleted': !task.isCompleted,
      });
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = 20.0;

    // Calculate task list height
    final taskListHeight = screenHeight -
        statusBarHeight - // Status bar
        80 - // Header height (approximate)
        40 - // Top/Bottom padding (20 each)
        50 - // Progress task text + padding
        180 - // Task progress section height (approximate)
        50 - // List Task text + padding
        100 - // Calendar height (approximate)
        bottomPadding; // Bottom spacing

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          "Your Progress Task",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      _buildTaskProgress(context),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          "List Task",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      _buildCalendar(),
                      Expanded(
                        child: _buildTasksList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => CreateTaskBottomSheet(
              initialDate: _selectedDate,
            ),
          );
        },
        backgroundColor: Colors.blue[600],
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/avatar.png'),
                backgroundColor: Colors.purple.shade100,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jhorgi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _getFormattedDate(), // Add date display
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Stack(
                  children: [
                    ImageIcon(
                      AssetImage('assets/ic_notification.png'),
                      size: 24,
                      color: Colors.black, // You can change the color
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: ImageIcon(
                  AssetImage('assets/ic_search3.png'),
                  size: 24,
                  color: Colors.black, // You can change the color
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskProgress(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildDoneTaskSection(context), _circularProgress()],
    );
  }

  Widget _buildDoneTaskSection(BuildContext context) {
    return Container(
      width: 160,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Color(0xFFE5E3FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _doneTaskHeader(),
          SizedBox(height: 5),
          SizedBox(
            // Add fixed height container
            height: 96, // 24 height per item * 4 items
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tasks')
                  .where('uid', isEqualTo: _userId)
                  .where('isCompleted', isEqualTo: true)
                  .orderBy('date', descending: true)
                  .limit(4)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!.docs
                    .map((doc) => Task.fromFirestore(doc))
                    .toList();

                if (tasks.isEmpty) {
                  return Text('No completed tasks');
                }

                return Column(
                  children: tasks.map((task) => _buildTaskItem(task)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    String emoji = _getEmojiForCategory(task.category);

    return Container(
      // Use Container instead of Padding for consistent height
      height: 24, // Fixed height for each item
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _getEmojiForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'work event':
        return '💼';
      case 'sport':
        return '🏃';
      case 'meeting':
        return '👥';
      case 'study':
        return '📚';
      case 'design':
        return '🎨';
      default:
        return '📝';
    }
  }

  Widget _doneTaskHeader() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('tasks')
          .where('uid', isEqualTo: _userId)
          .where('isCompleted', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        int completedCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            _circularListIcons(),
            Text(
              "$completedCount",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        );
      },
    );
  }

  Widget _circularListIcons() {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: Color(0xFFF0F0FF),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: SvgPicture.asset(
          'assets/ic_list.svg',
          color: Color(0xFF6B6B6B),
        ),
      ),
    );
  }

  Widget _circularProgress() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF2F5FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tasks')
            .where('uid', isEqualTo: _userId)
            .where('date',
                isGreaterThanOrEqualTo: DateTime(
                    _selectedDate.year, _selectedDate.month, _selectedDate.day))
            .where('date',
                isLessThan: DateTime(_selectedDate.year, _selectedDate.month,
                    _selectedDate.day + 1))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error loading progress');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final allTasks = snapshot.data?.docs ?? [];
          final totalTasks = allTasks.length;
          final completedTasks = allTasks.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isCompleted'] == true;
          }).length;

          // Calculate percentage
          final percentage =
              totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 50,
                lineWidth: 22,
                percent: percentage,
                center: Text(
                  "${(percentage * 100).toInt()}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                progressColor: Colors.lightBlue[300],
                backgroundColor: Colors.pink[200]!,
              ),
              SizedBox(height: 3),
              Text(
                "My Progress Task",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$completedTasks out of $totalTasks task done",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(Duration(days: 365)),
      lastDay: DateTime.now().add(Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _selectedDate = selectedDay; // Update _selectedDate to filter tasks
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      // Customize calendar style
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(color: Colors.black87),
        defaultTextStyle: TextStyle(color: Colors.black87),
        selectedDecoration: BoxDecoration(
          color: Colors.blue[600],
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue[600]!, width: 1),
        ),
        todayTextStyle: TextStyle(
          color: Colors.blue[600],
          fontWeight: FontWeight.bold,
        ),
      ),
      // Customize header style
      headerVisible: false, // Hide default header since we have our own
      // Customize days of week style
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        weekendStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      startingDayOfWeek: StartingDayOfWeek.monday,
      // Enable only horizontal swipe
      availableGestures: AvailableGestures.horizontalSwipe,
    );
  }

  // Optional: Add a method to format the selected date for display
  String _getFormattedDate() {
    return DateFormat('MMMM d, y').format(_selectedDate);
  }

  Widget _buildTasksList() {
    if (_userId == null) {
      return Center(child: Text('Please sign in to view tasks'));
    }

    // Create DateTime objects for start and end of the selected date
    final startOfDay =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('tasks')
          .where('uid', isEqualTo: _userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final tasks =
            snapshot.data!.docs.map((doc) => Task.fromFirestore(doc)).toList();

        if (tasks.isEmpty) {
          return Center(child: Text('No tasks for today'));
        }

        return ListView.separated(
          itemCount: tasks.length,
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Dismissible(
              key: Key(task.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) => _deleteTask(task.id),
              child: GestureDetector(
                onTap: () => _showEditTaskDialog(task),
                child: _buildTaskCard(
                  task.category,
                  task.subtitle,
                  task.time,
                  _getCategoryColor(task.category),
                  task: task,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard(
    String title,
    String subtitle,
    String time,
    Color color, {
    required Task task,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: () => _toggleTaskCompletion(task),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted ? Colors.green : Colors.grey,
                    ),
                  ),
                  child: task.isCompleted
                      ? Icon(Icons.check, size: 12, color: Colors.white)
                      : SizedBox(width: 12, height: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (time.isNotEmpty) ...[
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time, size: 16),
                SizedBox(width: 5),
                Text(time),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work event':
        return Colors.pink[50]!;
      case 'sport':
        return Colors.orange[50]!;
      default:
        return Colors.blue[50]!;
    }
  }

  void _showEditTaskDialog(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTaskBottomSheet(
        task: task,
        onUpdate: _updateTask,
      ),
    );
  }
}
