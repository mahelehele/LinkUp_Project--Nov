import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isDarkMode = false;
  int _selectedCategory = 0;

  final List<Event> _events = [
    Event(
      title: 'Tech Conference 2024',
      description: 'Annual technology conference featuring industry leaders',
      date: 'Dec 15, 2024',
      time: '09:00 AM',
      location: 'Main Auditorium',
      category: 'Tech',
      gradient: [Colors.pinkAccent, Colors.deepPurple],
      attendees: 120,
      isRegistered: true,
    ),
    Event(
      title: 'Study Group Session',
      description: 'Collaborative study session for Database Systems',
      date: 'Dec 12, 2024',
      time: '02:00 PM',
      location: 'Library Room 205',
      category: 'Academic',
      gradient: [Colors.blueAccent, Colors.teal],
      attendees: 15,
      isRegistered: true,
    ),
    Event(
      title: 'Career Fair',
      description: 'Connect with top employers and explore job opportunities',
      date: 'Dec 18, 2024',
      time: '10:00 AM',
      location: 'Student Center',
      category: 'Career',
      gradient: [Colors.orangeAccent, Colors.pink],
      attendees: 200,
      isRegistered: false,
    ),
    Event(
      title: 'Basketball Tournament',
      description: 'Inter-department basketball championship',
      date: 'Dec 20, 2024',
      time: '04:00 PM',
      location: 'Sports Complex',
      category: 'Sports',
      gradient: [Colors.redAccent, Colors.deepOrange],
      attendees: 50,
      isRegistered: false,
    ),
    Event(
      title: 'Art Exhibition',
      description: 'Showcasing student artwork and creative projects',
      date: 'Dec 22, 2024',
      time: '11:00 AM',
      location: 'Art Gallery',
      category: 'Arts',
      gradient: [Colors.purpleAccent, Colors.pinkAccent],
      attendees: 80,
      isRegistered: true,
    ),
  ];

  final List<String> _categories = ['All', 'Tech', 'Academic', 'Career', 'Sports', 'Arts'];

  @override
  void initState() {
    super.initState();
    _isDarkMode = StorageService.isDarkMode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _selectedCategory == 0
        ? _events
        : _events.where((e) => e.category == _categories[_selectedCategory]).toList();

    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : const Color(0xFFFFF1F3),
      appBar: AppBar(
        title: const Text(
          'Campus Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _searchEvents,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildCategoryFilter(),
          Expanded(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: filteredEvents.isEmpty
                      ? _buildEmptyState()
                      : _buildEventsList(filteredEvents),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createEvent,
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [Colors.pinkAccent, Colors.purpleAccent])
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsList(List<Event> events) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) => _buildEventCard(events[index]),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: event.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: event.gradient.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _viewEventDetails(event),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.white.withOpacity(0.9), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${event.date} • ${event.time}',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                event.description,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(event.location,
                          style: TextStyle(color: Colors.white.withOpacity(0.9))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${event.attendees}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No Events Found 😕',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  void _viewEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(event.title),
        content: Text(event.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.pinkAccent)),
          ),
        ],
      ),
    );
  }

  void _createEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event creation coming soon...')),
    );
  }

  void _searchEvents() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search coming soon...')),
    );
  }
}

class Event {
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String category;
  final List<Color> gradient;
  final int attendees;
  final bool isRegistered;

  Event({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.gradient,
    required this.attendees,
    required this.isRegistered,
  });
}
