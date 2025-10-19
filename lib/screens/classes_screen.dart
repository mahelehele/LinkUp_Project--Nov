import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDarkMode = false;
  int _selectedDay = DateTime.now().weekday - 1; // 0 = Monday

  final List<ClassSchedule> _classes = [
    ClassSchedule(
      name: 'Database Systems',
      time: '09:00 AM',
      duration: 90,
      location: 'Room 101',
      instructor: 'Dr. Smith',
      day: 0,
      color: Colors.pinkAccent,
    ),
    ClassSchedule(
      name: 'Web Development',
      time: '11:00 AM',
      duration: 120,
      location: 'Lab 205',
      instructor: 'Prof. Johnson',
      day: 0,
      color: Colors.deepPurpleAccent,
    ),
    ClassSchedule(
      name: 'Business Management',
      time: '02:00 PM',
      duration: 90,
      location: 'Room 301',
      instructor: 'Dr. Wilson',
      day: 1,
      color: Colors.orangeAccent,
    ),
    ClassSchedule(
      name: 'Mobile App Development',
      time: '10:00 AM',
      duration: 120,
      location: 'Lab 210',
      instructor: 'Prof. Davis',
      day: 2,
      color: Colors.tealAccent,
    ),
    ClassSchedule(
      name: 'Data Structures',
      time: '01:00 PM',
      duration: 90,
      location: 'Room 105',
      instructor: 'Dr. Brown',
      day: 3,
      color: Colors.redAccent,
    ),
    ClassSchedule(
      name: 'Software Engineering',
      time: '03:00 PM',
      duration: 120,
      location: 'Room 401',
      instructor: 'Prof. Miller',
      day: 4,
      color: Colors.purpleAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isDarkMode = StorageService.isDarkMode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayClasses = _classes.where((c) => c.day == _selectedDay).toList();

    return Scaffold(
      backgroundColor:
          _isDarkMode ? Colors.black : const Color(0xFFFFE4EC), // Light pink bg
      appBar: AppBar(
        title: const Text('My Classes'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Column(
            children: [
              _buildDaySelector(),
              Expanded(
                child: todayClasses.isEmpty
                    ? _buildEmptyState()
                    : _buildClassList(todayClasses),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClass,
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: const Color(0xFFFFC0CB),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDay;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.pinkAccent.withOpacity(0.9)
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? Colors.pink
                      : Colors.pinkAccent.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_hasClassesOnDay(index))
                    Icon(Icons.circle,
                        size: 6, color: Colors.white.withOpacity(0.8)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _hasClassesOnDay(int day) {
    return _classes.any((c) => c.day == day);
  }

  Widget _buildClassList(List<ClassSchedule> classes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        return _buildClassCard(classes[index], index);
      },
    );
  }

  Widget _buildClassCard(ClassSchedule classSchedule, int index) {
    final isNow = _isClassNow(classSchedule);

    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color:
              isNow ? Colors.pinkAccent.withOpacity(0.6) : Colors.transparent,
          width: isNow ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 60,
              decoration: BoxDecoration(
                color: classSchedule.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classSchedule.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildClassDetail(Icons.access_time, classSchedule.time),
                  _buildClassDetail(
                      Icons.location_on_outlined, classSchedule.location),
                  _buildClassDetail(Icons.person_outline,
                      'Instructor: ${classSchedule.instructor}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  bool _isClassNow(ClassSchedule classSchedule) {
    return classSchedule.time.contains('09:00') ||
        classSchedule.time.contains('02:00');
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school,
              size: 80, color: Colors.pinkAccent.withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text(
            'No Classes Today 🎉',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Enjoy your free time!',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  void _addClass() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add New Class',
            style: TextStyle(color: Colors.pinkAccent)),
        content: const Text(
          'Feature coming soon!',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.pinkAccent)),
          ),
        ],
      ),
    );
  }
}

class ClassSchedule {
  final String name;
  final String time;
  final int duration;
  final String location;
  final String instructor;
  final int day;
  final Color color;

  ClassSchedule({
    required this.name,
    required this.time,
    required this.duration,
    required this.location,
    required this.instructor,
    required this.day,
    required this.color,
  });
}
