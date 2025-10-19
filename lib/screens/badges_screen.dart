import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _colorAnimation;
  bool _isDarkMode = false;
  final List<Badge> _badges = [
    Badge(name: 'First Post', description: 'Created your first post', color: Colors.blue, icon: Icons.create, progress: 1.0),
    Badge(name: 'Social Butterfly', description: 'Connected with 10+ students', color: Colors.green, icon: Icons.people, progress: 0.7),
    Badge(name: 'Event Explorer', description: 'Attended 5 events', color: Colors.orange, icon: Icons.event, progress: 0.4),
    Badge(name: 'Group Leader', description: 'Created 3 study groups', color: Colors.purple, icon: Icons.group, progress: 0.2),
    Badge(name: 'Scholar', description: 'Perfect attendance for 1 month', color: Colors.red, icon: Icons.school, progress: 0.8),
    Badge(name: 'Helper', description: 'Helped 5 classmates', color: Colors.teal, icon: Icons.help, progress: 0.6),
  ];

  @override
  void initState() {
    super.initState();
    _isDarkMode = StorageService.isDarkMode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _colorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('My Badges'),
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        foregroundColor: _isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context),
              ),
              SliverToBoxAdapter(
                child: _buildStats(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildBadgeCard(_badges[index], index);
                    },
                    childCount: _badges.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [Colors.grey[900]!, Colors.black]
              : [Colors.grey[100]!, Colors.white],
        ),
      ),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(_colorAnimation.value),
                  Colors.orange.withOpacity(_colorAnimation.value),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3 * _colorAnimation.value),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.workspace_premium,
              size: 40,
              color: Colors.white.withOpacity(_colorAnimation.value),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Achievement Badges',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock badges by being active in the community',
            style: TextStyle(
              fontSize: 14,
              color: _isDarkMode ? Colors.grey : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final unlocked = _badges.where((badge) => badge.progress == 1.0).length;
    final total = _badges.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('$unlocked', 'Unlocked', Icons.check_circle, Colors.green),
          _buildStatItem('${total - unlocked}', 'Locked', Icons.lock, Colors.orange),
          _buildStatItem('${((unlocked / total) * 100).toInt()}%', 'Progress', Icons.trending_up, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(_colorAnimation.value * 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: color.withOpacity(_colorAnimation.value),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _isDarkMode ? Colors.grey : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Badge badge, int index) {
    final isUnlocked = badge.progress == 1.0;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isUnlocked ? badge.color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.color.withOpacity(isUnlocked ? _colorAnimation.value * 0.2 : 0.1),
                  border: Border.all(
                    color: badge.color.withOpacity(isUnlocked ? _colorAnimation.value * 0.5 : 0.2),
                    width: 2,
                  ),
                ),
              ),
              Icon(
                badge.icon,
                size: 30,
                color: isUnlocked ? badge.color.withOpacity(_colorAnimation.value) : Colors.grey,
              ),
              if (!isUnlocked)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Icons.lock,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            badge.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isUnlocked 
                  ? badge.color.withOpacity(_colorAnimation.value)
                  : (_isDarkMode ? Colors.grey : Colors.grey[600]),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            style: TextStyle(
              fontSize: 10,
              color: _isDarkMode ? Colors.grey : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: badge.progress,
            backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
            color: badge.color,
            minHeight: 4,
          ),
          const SizedBox(height: 4),
          Text(
            '${(badge.progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              color: _isDarkMode ? Colors.grey : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class Badge {
  final String name;
  final String description;
  final Color color;
  final IconData icon;
  final double progress;

  Badge({
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.progress,
  });
}