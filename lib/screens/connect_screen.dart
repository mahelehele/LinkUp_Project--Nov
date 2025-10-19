import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  LatLng _currentCenter = const LatLng(-25.7479, 28.2293);
  bool _isDarkMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _getCurrentLocation();
  }

  void _loadStudents() {
    _students = [
      // APK Campus
      {
        'name': 'Sarah Johnson',
        'field': 'Computer Science',
        'campus': 'APK',
        'year': '3rd Year',
        'interests': 'AI, Flutter, Coding Challenges',
        'location': const LatLng(-25.7479, 28.2293),
        'color': Colors.pinkAccent,
      },
      {
        'name': 'Michael Lee',
        'field': 'Software Engineering',
        'campus': 'APK',
        'year': '2nd Year',
        'interests': 'Hackathons, Robotics, Gaming',
        'location': const LatLng(-25.7488, 28.2310),
        'color': Colors.redAccent,
      },

      // APB Campus
      {
        'name': 'David Wilson',
        'field': 'Business Management',
        'campus': 'APB',
        'year': '3rd Year',
        'interests': 'Finance, Startups, Networking',
        'location': const LatLng(-25.7545, 28.2315),
        'color': Colors.blueAccent,
      },
      {
        'name': 'Thandi Nkosi',
        'field': 'Marketing',
        'campus': 'APB',
        'year': '2nd Year',
        'interests': 'Branding, Content Creation, Public Speaking',
        'location': const LatLng(-25.7552, 28.2322),
        'color': Colors.lightBlueAccent,
      },

      // SWC Campus
      {
        'name': 'Emma Davis',
        'field': 'Medicine',
        'campus': 'SWC',
        'year': '4th Year',
        'interests': 'Healthcare Tech, Research, Volunteering',
        'location': const LatLng(-25.7498, 28.2271),
        'color': Colors.purpleAccent,
      },
      {
        'name': 'Sipho Dlamini',
        'field': 'Nursing Science',
        'campus': 'SWC',
        'year': '3rd Year',
        'interests': 'Community Health, Fitness, Reading',
        'location': const LatLng(-25.7503, 28.2282),
        'color': Colors.deepPurpleAccent,
      },
    ];
    _filteredStudents = List.from(_students);
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);
      Position pos = await Geolocator.getCurrentPosition();
      setState(() {
        _currentCenter = LatLng(pos.latitude, pos.longitude);
        _mapController.move(_currentCenter, 14);
      });
    } catch (e) {
      debugPrint('Location error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _searchStudents(String query) {
    setState(() {
      _filteredStudents = _students
          .where((s) =>
              s['name'].toLowerCase().contains(query.toLowerCase()) ||
              s['field'].toLowerCase().contains(query.toLowerCase()) ||
              s['campus'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showStudentInfo(Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _isDarkMode ? Colors.black87 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: student['color'],
              radius: 45,
              child: const Icon(Icons.person, size: 45, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              student['name'],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${student['field']} • ${student['campus']} Campus\n${student['year']}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '🎯 Interests: ${student['interests']}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isDarkMode ? Colors.grey[200] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar(
                    "Connection request sent to ${student['name']} 💬");
              },
              icon: const Icon(Icons.link),
              label: const Text('Connect'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.pinkAccent,
                side: const BorderSide(color: Colors.pinkAccent),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.pinkAccent,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('Connect with Students',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: _isDarkMode
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.campus_connect',
              ),
              MarkerLayer(
                markers: _filteredStudents.map((student) {
                  return Marker(
                    width: 45,
                    height: 45,
                    point: student['location'],
                    child: GestureDetector(
                      onTap: () => _showStudentInfo(student),
                      child: Icon(
                        Icons.location_pin,
                        color: student['color'],
                        size: 45,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Search bar
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchStudents,
                decoration: const InputDecoration(
                  hintText: 'Search students, campus or field...',
                  prefixIcon: Icon(Icons.search, color: Colors.pinkAccent),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Overlay Info
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '🌍 Students Around You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_filteredStudents.length} active nearby',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent)),
        ],
      ),
    );
  }
}

