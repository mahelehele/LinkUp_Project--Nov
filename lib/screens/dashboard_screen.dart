import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart'; // For date formatting
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'badges_screen.dart';
import 'classes_screen.dart';
import 'events_screen.dart';
import 'posts_screen.dart';
import 'ai_chatbot_screen.dart';
import 'connect_screen.dart'; // 👈 Added back

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isDarkMode = false;
  final AuthService _authService = AuthService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String get currentDate =>
      DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadThemePreference() {
    setState(() {
      _isDarkMode = StorageService.isDarkMode();
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    StorageService.setDarkMode(_isDarkMode);
  }

  void _logout(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/signin');
  }

  void _animateButton(int index) async {
    await _animationController.forward();
    await _animationController.reverse();
  }

  void _navigateToScreen(BuildContext context, String route) {
    switch (route) {
      case '/connect':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectScreen()));
        break;
      case '/events':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsScreen()));
        break;
      case '/classes':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassesScreen()));
        break;
      case '/posts':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PostsScreen()));
        break;
      case '/badges':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BadgesScreen()));
        break;
      case '/ai':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatbotScreen()));
        break;
      default:
        _showComingSoon(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF2C0B1D) : const Color(0xFFFFC0CB);
    final appBarColor = _isDarkMode ? Colors.pink.shade900 : Colors.pinkAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Campus Connect',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarColor,
        elevation: 3,
        shadowColor: Colors.pinkAccent.withOpacity(0.3),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUserHeader(context),
          Expanded(
            child: Center(
              child: _buildCircularDashboard(context),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () => _navigateToScreen(context, '/ai'),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    final userName = StorageService.getUserName().isEmpty
        ? "Student"
        : StorageService.getUserName();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.pink.shade900 : Colors.pinkAccent,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentDate,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Welcome back, $userName 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                StorageService.getUserEmail(),
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularDashboard(BuildContext context) {
    final List<DashboardItem> items = [
      DashboardItem(Icons.people, 'Connect', Colors.pink.shade400, '/connect'),
      DashboardItem(Icons.event, 'Events', Colors.pink.shade400, '/events'),
      DashboardItem(Icons.class_, 'Classes', Colors.pink.shade300, '/classes'),
      DashboardItem(Icons.article, 'Posts', Colors.pink.shade200, '/posts'),
      DashboardItem(Icons.workspace_premium, 'Badges', Colors.pink.shade400, '/badges'),
      DashboardItem(Icons.chat, 'AI Chat', Colors.pink.shade600, '/ai'),
    ];

    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        children: [
          ...List.generate(items.length, (index) {
            final angle = 2 * pi * index / items.length;
            const radius = 120.0;
            final x = radius * cos(angle);
            final y = radius * sin(angle);

            return Positioned(
              left: 160 + x - 30,
              top: 160 + y - 30,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
                child: _buildCircularButton(context, items[index], index),
              ),
            );
          }),
          Positioned(
            left: 135,
            top: 135,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isDarkMode ? Colors.pink.shade800 : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.school,
                color: _isDarkMode ? Colors.white : Colors.pinkAccent,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(BuildContext context, DashboardItem item, int index) {
    return GestureDetector(
      onTapDown: (_) => _animateButton(index),
      onTap: () => _navigateToScreen(context, item.route),
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: item.color,
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: Colors.white, size: 22),
            const SizedBox(height: 3),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Coming Soon'),
        content: const Text('This feature is under development.'),
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

class DashboardItem {
  final IconData icon;
  final String title;
  final Color color;
  final String route;

  DashboardItem(this.icon, this.title, this.color, this.route);
}
