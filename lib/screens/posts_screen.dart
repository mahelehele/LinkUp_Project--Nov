import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDarkMode = false;
  bool _isLoading = true;
  bool _isCreatingPost = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();

  List<Post> _posts = [];
  String? _editingPostId;

  final String _baseUrl = 'https://jsj-server.onrender.com/api';

  // 🟦 Get headers (simulate auth token)
  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'authorization': 'student_123456789', // TODO: replace with session from storage
    };
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _loadSettings();
    _loadPosts();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  // 🟩 Load posts from API or cache
  Future<void> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      setState(() => _isLoading = true);
      final response = await http.get(Uri.parse('$_baseUrl/posts'),
          headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final postsData = data['posts'] as List;
        final loadedPosts =
            postsData.map((e) => Post.fromJson(e)).toList(growable: false);

        setState(() {
          _posts = loadedPosts;
          _isLoading = false;
        });

        // Save to cache
        prefs.setString('cachedPosts', json.encode(postsData));
        _animationController.forward();
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      // Load cached posts if offline
      final cached = prefs.getString('cachedPosts');
      if (cached != null) {
        final postsData = json.decode(cached) as List;
        setState(() {
          _posts =
              postsData.map((e) => Post.fromJson(e)).toList(growable: false);
        });
      }
      _showSnack('Failed to load posts: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  // 🟨 Create or update post
  Future<void> _savePost() async {
    final title = _titleController.text.trim();
    final caption = _captionController.text.trim();
    if (title.isEmpty) {
      _showSnack('Please enter a title', isError: true);
      return;
    }

    setState(() => _isCreatingPost = true);
    final Map<String, dynamic> postData = {
      'title': title,
      if (caption.isNotEmpty) 'caption': caption,
    };

    try {
      final url = _editingPostId == null
          ? Uri.parse('$_baseUrl/posts')
          : Uri.parse('$_baseUrl/posts/$_editingPostId');
      final response = _editingPostId == null
          ? await http.post(url, headers: _headers, body: json.encode(postData))
          : await http.put(url, headers: _headers, body: json.encode(postData));

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnack(_editingPostId == null
            ? 'Post created successfully!'
            : 'Post updated successfully!');
        _titleController.clear();
        _captionController.clear();
        _editingPostId = null;
        _loadPosts();
      } else {
        _showSnack('Error: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnack('Failed to save post: $e', isError: true);
    } finally {
      setState(() => _isCreatingPost = false);
    }
  }

  // 🟥 Delete post
  Future<void> _deletePost(String id) async {
    try {
      final res =
          await http.delete(Uri.parse('$_baseUrl/posts/$id'), headers: _headers);
      if (res.statusCode == 200) {
        _showSnack('Post deleted successfully!');
        _loadPosts();
      } else {
        _showSnack('Delete failed: ${res.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnack('Delete failed: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _editPost(Post post) {
    setState(() {
      _editingPostId = post.id.toString();
      _titleController.text = post.title;
      _captionController.text = post.caption ?? '';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  // 🧱 UI
  @override
  Widget build(BuildContext context) {
    final bg = _isDarkMode ? Colors.black : Colors.grey[100];
    final text = _isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: _loadPosts,
              icon: const Icon(Icons.refresh, color: Colors.blue))
        ],
      ),
      body: Column(
        children: [
          _buildCreatePostCard(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                    ? _buildEmpty()
                    : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              prefixIcon: Icon(Icons.title),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              labelText: 'Caption',
              prefixIcon: Icon(Icons.message),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _isCreatingPost ? null : _savePost,
            icon: _isCreatingPost
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Icon(_editingPostId == null ? Icons.send : Icons.save),
            label: Text(
                _editingPostId == null ? 'Publish Post' : 'Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _posts.length,
        itemBuilder: (context, i) {
          final post = _posts[i];
          return AnimatedOpacity(
            opacity: _fadeAnimation.value,
            duration: Duration(milliseconds: 300 + i * 50),
            child: Card(
              color: _isDarkMode ? Colors.grey[850] : Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Colors.blue.withOpacity(_fadeAnimation.value * 0.8),
                  child: Text(
                    post.creatorFullName.isNotEmpty
                        ? post.creatorFullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(post.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black)),
                subtitle: Text(
                  post.caption ?? '',
                  style: TextStyle(
                      color: _isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deletePost(post.id.toString()),
                ),
                onTap: () => _editPost(post),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.forum_outlined,
                  size: 64, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 12),
              Text('No posts yet',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _isDarkMode ? Colors.white : Colors.black)),
              const SizedBox(height: 6),
              Text('Start the conversation by creating a post!',
                  style: TextStyle(
                      color: _isDarkMode ? Colors.grey : Colors.grey[600])),
            ],
          ),
        ),
      );
}

class Post {
  final int id;
  final String title;
  final String? caption;
  final String createdBy;
  final String createdAt;
  final String creatorFirstName;
  final String creatorSurname;

  Post({
    required this.id,
    required this.title,
    this.caption,
    required this.createdBy,
    required this.createdAt,
    required this.creatorFirstName,
    required this.creatorSurname,
  });

  String get creatorFullName => '$creatorFirstName $creatorSurname';

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      caption: json['caption'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      creatorFirstName: json['creator_name'] ?? 'Unknown',
      creatorSurname: json['creator_surname'] ?? '',
    );
  }
}
