// Add this new widget class:
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CreateTaskBottomSheet extends StatefulWidget {
  final Task? task;
  final Function(Task)? onUpdate;
  final DateTime? initialDate;

  const CreateTaskBottomSheet({
    super.key,
    this.task,
    this.onUpdate,
    this.initialDate,
  });

  @override
  State<CreateTaskBottomSheet> createState() => _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends State<CreateTaskBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _timeController;
  late String _category;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _subtitleController =
        TextEditingController(text: widget.task?.subtitle ?? '');
    _timeController = TextEditingController(text: widget.task?.time ?? '');
    _category = widget.task?.category ?? 'Work Event';
    _selectedDate = widget.task?.date ?? widget.initialDate ?? DateTime.now();
    if (widget.task?.time != null && widget.task!.time.isNotEmpty) {
      try {
        final timeParts = widget.task!.time.split(':');
        if (timeParts.length == 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          _timeController.text = _formatTime(_selectedTime!);
        }
      } catch (e) {
        print('Error parsing time: $e');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _formatTime(picked);
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String _getFormattedDate() {
    return DateFormat('MMM d, y').format(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.videocam_outlined,
                      color: Colors.blue,
                      size: 35,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 10, // Make the edit icon smaller
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      // padding: EdgeInsets.on(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '  Title',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // IconButton(
              //   icon: Icon(Icons.link, color: Colors.grey),
              //   onPressed: () {},
              // ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 20),
                            SizedBox(width: 8),
                            Text(_getFormattedDate()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 20),
                            SizedBox(width: 8),
                            Text(
                              _selectedTime != null
                                  ? _formatTime(_selectedTime!)
                                  : 'Select time',
                              style: TextStyle(
                                color: _selectedTime != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Description',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Container(
            // padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _subtitleController,
              decoration: InputDecoration(
                hintText: '  What you wanna do?',
                border: InputBorder.none,
              ),
              // maxLines: 2,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Team Members',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < 4; i++)
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundImage: AssetImage('assets/avatar.png'),
                    backgroundColor: Colors.purple.shade100,
                  ),
                ),
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Location',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(height: 2),
                  SizedBox(width: 16),
                  Expanded(
                    // Add this
                    child: TextField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        hintText: '  https://meet.google.com/cjc-gxhm-zi?...',
                        border: InputBorder.none,
                        prefixIcon: SvgPicture.asset('assets/meet.svg'),
                        prefixIconConstraints: BoxConstraints(
                          maxHeight: 18,
                          maxWidth: 18,
                        ),
                        contentPadding: EdgeInsets.only(left: 12),
                      ),
                    ),
                  ),
                ],
              )),
          SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              if (_userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please sign in to create tasks')),
                );
                return;
              }

              final task = Task(
                id: widget.task?.id ?? DateTime.now().toString(),
                uid: _userId!,
                title: _titleController.text,
                subtitle: _subtitleController.text,
                time: _selectedTime != null ? _formatTime(_selectedTime!) : '',
                category: _category,
                date: _selectedDate,
              );

              if (widget.task != null) {
                widget.onUpdate?.call(task);
              } else {
                FirebaseFirestore.instance
                    .collection('tasks')
                    .add(task.toMap());
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              minimumSize: Size(double.infinity, 50),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Create Task',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          //   child: Text(
          //     'Create Task',
          //     style: TextStyle(color: Colors.white),
          //   ),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.blue[600],
          //     minimumSize: Size(double.infinity, 50),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //   ),
          // ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
