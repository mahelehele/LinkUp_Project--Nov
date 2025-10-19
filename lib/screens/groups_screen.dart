import 'package:flutter/material.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final List<Group> _allGroups = [];
  final List<Group> _filteredGroups = [];
  final TextEditingController _searchController = TextEditingController();
  GroupFilter _currentFilter = GroupFilter.all;

  @override
  void initState() {
    super.initState();
    _initializeDummyData();
    _filteredGroups.addAll(_allGroups);
  }

  void _initializeDummyData() {
    _allGroups.addAll([
      Group(
        id: '1',
        name: 'Family Chat',
        description: 'Family group for important updates',
        memberCount: 12,
        imageUrl: '',
        lastMessage: 'Mom: Dinner at 7 PM tomorrow!',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
        isMuted: false,
        unreadCount: 3,
      ),
      Group(
        id: '2',
        name: 'Work Team',
        description: 'Official work discussions',
        memberCount: 8,
        imageUrl: '',
        lastMessage: 'John: Meeting moved to 3 PM',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        isMuted: true,
        unreadCount: 0,
      ),
      Group(
        id: '3',
        name: 'College Friends',
        description: 'College buddies reunion',
        memberCount: 25,
        imageUrl: '',
        lastMessage: 'Sarah: Who\'s coming to the party?',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
        isMuted: false,
        unreadCount: 12,
      ),
      Group(
        id: '4',
        name: 'Project Alpha',
        description: 'Project collaboration space',
        memberCount: 6,
        imageUrl: '',
        lastMessage: 'You: I\'ll push the code tonight',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        isMuted: false,
        unreadCount: 1,
      ),
      Group(
        id: '5',
        name: 'Gaming Squad',
        description: 'Let\'s play together!',
        memberCount: 15,
        imageUrl: '',
        lastMessage: 'Mike: New game released today!',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
        isMuted: true,
        unreadCount: 0,
      ),
      Group(
        id: '6',
        name: 'Book Club',
        description: 'Monthly book discussions',
        memberCount: 10,
        imageUrl: '',
        lastMessage: 'Lisa: Next book is "The Alchemist"',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
        isMuted: false,
        unreadCount: 5,
      ),
      Group(
        id: '7',
        name: 'Travel Buddies',
        description: 'Plan your next adventure',
        memberCount: 7,
        imageUrl: '',
        lastMessage: 'Alex: Bali trip confirmed!',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        isMuted: false,
        unreadCount: 2,
      ),
      Group(
        id: '8',
        name: 'Study Group',
        description: 'Learning together',
        memberCount: 4,
        imageUrl: '',
        lastMessage: 'Emma: Chapter 5 notes uploaded',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 12)),
        isMuted: false,
        unreadCount: 0,
      ),
    ]);
  }

  void _filterGroups(String query) {
    setState(() {
      _filteredGroups.clear();
      
      if (query.isEmpty) {
        _filteredGroups.addAll(_allGroups);
      } else {
        _filteredGroups.addAll(
          _allGroups.where((group) =>
            group.name.toLowerCase().contains(query.toLowerCase()) ||
            group.description.toLowerCase().contains(query.toLowerCase())),
        );
      }
      
      _applyCurrentFilter();
    });
  }

  void _applyCurrentFilter() {
    switch (_currentFilter) {
      case GroupFilter.all:
        // No additional filtering needed
        break;
      case GroupFilter.unread:
        _filteredGroups.removeWhere((group) => group.unreadCount == 0);
        break;
      case GroupFilter.muted:
        _filteredGroups.removeWhere((group) => !group.isMuted);
        break;
    }
  }

  void _changeFilter(GroupFilter filter) {
    setState(() {
      _currentFilter = filter;
      _filterGroups(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterGroups,
              decoration: InputDecoration(
                hintText: 'Search groups...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildFilterChip('All', GroupFilter.all),
                const SizedBox(width: 8),
                _buildFilterChip('Unread', GroupFilter.unread),
                const SizedBox(width: 8),
                _buildFilterChip('Muted', GroupFilter.muted),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Groups List
          Expanded(
            child: _filteredGroups.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No groups found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = _filteredGroups[index];
                      return _GroupListItem(
                        group: group,
                        onTap: () {
                          // Handle group tap - you can navigate to group chat screen
                          _showGroupDetails(group);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, GroupFilter filter) {
    return FilterChip(
      label: Text(label),
      selected: _currentFilter == filter,
      onSelected: (selected) => _changeFilter(filter),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.teal,
      labelStyle: TextStyle(
        color: _currentFilter == filter ? Colors.white : Colors.black,
      ),
    );
  }

  void _showGroupDetails(Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(group.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${group.description}'),
            const SizedBox(height: 8),
            Text('Members: ${group.memberCount}'),
            const SizedBox(height: 8),
            Text('Last message: ${group.lastMessage}'),
            const SizedBox(height: 8),
            Text('Muted: ${group.isMuted ? 'Yes' : 'No'}'),
            const SizedBox(height: 8),
            Text('Unread messages: ${group.unreadCount}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _GroupListItem extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;

  const _GroupListItem({
    super.key,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.teal,
        radius: 25,
        child: Text(
          group.name[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              group.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (group.isMuted)
            const Icon(Icons.volume_off, size: 16, color: Colors.grey),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${group.memberCount} members',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(group.lastMessageTime),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          if (group.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                group.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

class Group {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final String imageUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isMuted;
  final int unreadCount;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    required this.imageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isMuted,
    required this.unreadCount,
  });
}

enum GroupFilter {
  all,
  unread,
  muted,
}