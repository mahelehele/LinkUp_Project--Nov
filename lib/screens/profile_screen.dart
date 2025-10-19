import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;
  bool _isLoadingProfile = true;

  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  // User data that will be loaded from backend/storage
  Map<String, dynamic> _userData = {
    'name': '',
    'surname': '',
    'student_number': '',
    'email': '',
    'phone_number': '',
    'course_name': '',
    'year_of_study': '',
    'faculty_name': '',
    'campus_name': '',
    'bio': 'Passionate student looking to connect with peers.',
    'join_date': '2023-02-15',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      // Try to load from backend first
      await _loadUserDataFromBackend();
    } catch (error) {
      print('Error loading from backend: $error');
      // Fallback to cached data
      await _loadUserDataFromCache();
    }

    setState(() {
      _isLoadingProfile = false;
    });
  }

  Future<void> _loadUserDataFromBackend() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null && currentUser['student_number'] != null) {
        final response = await _apiService.get('/students/${currentUser['student_number']}');
        
        if (response['success'] == true && response['student'] != null) {
          setState(() {
            _userData = Map<String, dynamic>.from(response['student']);
            _populateControllers();
          });
          
          // Cache the user data
          await _cacheUserData(_userData);
          return;
        }
      }
      
      // If backend fails, load from cache
      await _loadUserDataFromCache();
    } catch (error) {
      print('Backend load error: $error');
      await _loadUserDataFromCache();
    }
  }

  Future<void> _loadUserDataFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUserData = prefs.getString('cached_user_profile');
    
    if (cachedUserData != null) {
      try {
        final userData = Map<String, dynamic>.from(json.decode(cachedUserData));
        setState(() {
          _userData = userData;
          _populateControllers();
        });
      } catch (e) {
        print('Error loading cached data: $e');
      }
    } else {
      // Load basic user data from auth service
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        setState(() {
          _userData.addAll(currentUser);
          _populateControllers();
        });
      }
    }
  }

  void _populateControllers() {
    _nameController.text = _userData['name'] ?? '';
    _surnameController.text = _userData['surname'] ?? '';
    _emailController.text = _userData['email'] ?? '';
    _phoneController.text = _userData['phone_number'] ?? _userData['phone'] ?? '';
    _bioController.text = _userData['bio'] ?? 'Passionate student looking to connect with peers.';
  }

  Future<void> _cacheUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user_profile', json.encode(userData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (!_isEditing && !_isLoadingProfile)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: _startEditing,
            ),
          if (_isLoadingProfile)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 24),
                    _buildUniversityInfoSection(),
                    const SizedBox(height: 24),
                    if (_isEditing) _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.black54,
              ),
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    onPressed: _changeProfilePicture,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${_userData['name']} ${_userData['surname']}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userData['student_number'] ?? 'N/A',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _userData['course_name'] ?? _userData['course'] ?? 'Student',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline, color: Colors.black, size: 20),
                SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: 'Name',
              controller: _nameController,
              icon: Icons.person,
              isEditable: _isEditing,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              label: 'Surname',
              controller: _surnameController,
              icon: Icons.person_outline,
              isEditable: _isEditing,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email,
              isEditable: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildEditableField(
              label: 'Phone Number',
              controller: _phoneController,
              icon: Icons.phone,
              isEditable: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildBioField(),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversityInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.school, color: Colors.black, size: 20),
                SizedBox(width: 8),
                Text(
                  'University Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField(
              label: 'Student Number',
              value: _userData['student_number'] ?? 'N/A',
              icon: Icons.badge,
            ),
            const SizedBox(height: 12),
            _buildReadOnlyField(
              label: 'Course',
              value: _userData['course_name'] ?? _userData['course'] ?? 'Not specified',
              icon: Icons.menu_book,
            ),
            const SizedBox(height: 12),
            _buildReadOnlyField(
              label: 'Year of Study',
              value: _userData['year_of_study'] ?? _userData['year'] ?? 'Not specified',
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildReadOnlyField(
              label: 'Faculty',
              value: _userData['faculty_name'] ?? _userData['faculty'] ?? 'Not specified',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 12),
            _buildReadOnlyField(
              label: 'Campus',
              value: _userData['campus_name'] ?? _userData['campus'] ?? 'Not specified',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 12),
            _buildReadOnlyField(
              label: 'Member Since',
              value: _formatDate(_userData['join_date'] ?? _userData['joinDate'] ?? '2023-02-15'),
              icon: Icons.event_available,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditable,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: isEditable,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: Colors.black54),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        filled: !isEditable,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label.toLowerCase().contains('email') && 
            !RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        if (label.toLowerCase().contains('phone') && 
            !RegExp(r'^\d{10}$').hasMatch(value)) {
          return 'Phone number must be 10 digits';
        }
        return null;
      },
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      enabled: _isEditing,
      maxLines: 3,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: 'Bio',
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: const Icon(Icons.description, color: Colors.black54),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        filled: !_isEditing,
        fillColor: Colors.grey[50],
        hintText: 'Tell us about yourself...',
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline, color: Colors.grey[500], size: 16),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _cancelEditing,
            icon: const Icon(Icons.cancel, color: Colors.black),
            label: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.black),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.black),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveChanges,
            icon: _isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save, size: 20),
            label: _isLoading
                ? const Text('SAVING...')
                : const Text(
                    'SAVE CHANGES',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _populateControllers(); // Reset to original values
    });
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.updateProfile({
          'student_number': _userData['student_number'],
          'name': _nameController.text,
          'surname': _surnameController.text,
          'email': _emailController.text,
          'phone_number': _phoneController.text,
          'bio': _bioController.text,
        });

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Update local user data
          setState(() {
            _userData['name'] = _nameController.text;
            _userData['surname'] = _surnameController.text;
            _userData['email'] = _emailController.text;
            _userData['phone_number'] = _phoneController.text;
            _userData['bio'] = _bioController.text;
            _isEditing = false;
          });

          // Update cached data
          await _cacheUserData(_userData);

          _showSuccessDialog('Profile Updated', 'Your personal information has been updated successfully.');
        } else {
          _showErrorDialog('Update Failed', result['error'] ?? 'Failed to update profile. Please try again.');
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Update Error', 'An error occurred: $error');
      }
    }
  }

  void _changeProfilePicture() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Change Profile Picture',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            'Select an option to update your profile picture',
            style: TextStyle(color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement camera logic
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Take Photo', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement gallery logic
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Choose from Gallery', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.black, size: 48),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.done, size: 18),
                label: const Text('CONTINUE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(color: Colors.black),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}

// Add this import at the top of your file
