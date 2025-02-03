import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mypersonalapp/widgets/create_task_bottom_sheet.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = 20.0; // Space you want to leave at bottom

    // Calculate task list height
    final taskListHeight = screenHeight -
        statusBarHeight - // Status bar
        80 - // Header height (approximate)
        40 - // Top/Bottom padding (20 each)
        50 - // Progress task text + padding
        180 - // Task progress section height (approximate)
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
                      Text(
                        "Your Progress Task",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      _buildTaskProgress(context),
                      SizedBox(height: 20),
                      _buildCalendar(),
                      SizedBox(
                          height: taskListHeight, child: _buildTasksList()),
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
            builder: (context) => CreateTaskBottomSheet(),
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
              Text(
                'Jhorgi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
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
          _buildTaskItem('📚 Read a Book'),
          _buildTaskItem('👥 Weekly Meet'),
          _buildTaskItem('🎨 3D Designing'),
          _buildTaskItem('📝 Meeting With...'),
        ],
      ),
    );
  }

  Widget _doneTaskHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        _circularListIcons(),
        Text(
          "6",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
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
    // F2F5FF
    return Container(
      // height: 150,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF2F5FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 22,
            percent: 0.8,
            center: Text(
              "80%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            progressColor: Colors.lightBlue[300], // Lighter blue color
            backgroundColor: Colors.pink[200]!, // Lighter pink color
            // circularStrokeCap: CircularStrokeCap.round, // Rounded ends
          ),
          SizedBox(height: 3), // Add spacing
          Text(
            "My Progress Task",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "6 out 10 task done",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(text),
    );
  }

  // Widget _buildCalendar() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'List task',
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       SizedBox(height: 10),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           _buildCalendarDay('Mon', '1'),
  //           _buildCalendarDay('Tue', '2'),
  //           _buildCalendarDay('Wed', '3'),
  //           _buildCalendarDay('Thu', '4', isSelected: true),
  //           _buildCalendarDay('Fri', '5'),
  //           _buildCalendarDay('Sat', '6'),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildCalendarDay(String day, String date, {bool isSelected = false}) {
  //   return Column(
  //     children: [
  //       Text(
  //         day,
  //         style: TextStyle(
  //           color: Colors.grey,
  //           fontSize: 12,
  //         ),
  //       ),
  //       SizedBox(height: 5),
  //       Container(
  //         padding: EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           color: isSelected ? Colors.blue : null,
  //           shape: BoxShape.circle,
  //         ),
  //         child: Text(
  //           date,
  //           style: TextStyle(
  //             color: isSelected ? Colors.white : Colors.black,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  final DateTime _focusedDay = DateTime.now();
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(Duration(days: 365)),
      lastDay: DateTime.now().add(Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.week,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerVisible: false,
      daysOfWeekVisible: true,
      sixWeekMonthsEnforced: false,
      shouldFillViewport: false,

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

      // Customize available gestures
      availableGestures: AvailableGestures.horizontalSwipe,

      // Selected day callback
      selectedDayPredicate: (day) {
        return isSameDay(day, _focusedDay);
      },

      // Optional: Add these if you want to handle day selection
      onDaySelected: (selectedDay, focusedDay) {
        // Handle day selection
      },

      // Optional: Add this if you want to handle page changes
      onPageChanged: (focusedDay) {
        // Handle page change
      },
    );
  }

  Widget _buildTasksList() {
    return ListView(
      children: [
        _buildTaskCard(
          'Work Event',
          'Townhall meeting online',
          '7:00 am - 9:00 am',
          Colors.pink[50]!,
        ),
        SizedBox(height: 10),
        _buildTaskCard(
          'Work Event',
          'Discussing about project',
          '7:00 am - 9:00 am',
          Colors.blue[50]!,
        ),
        SizedBox(height: 10),
        _buildTaskCard(
          'Sport',
          'Running with my friend',
          '',
          Colors.orange[50]!,
        ),
        SizedBox(height: 10),
        _buildTaskCard(
          'Sport',
          'Running with my friend',
          '',
          Colors.orange[50]!,
        ),
        SizedBox(height: 10),
        _buildTaskCard(
          'Sport',
          'Running with my friend',
          '',
          Colors.orange[50]!,
        ),
      ],
    );
  }

  Widget _buildTaskCard(
      String title, String subtitle, String time, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
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
}
