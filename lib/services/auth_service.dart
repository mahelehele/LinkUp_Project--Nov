import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final ApiService _apiService = ApiService();

  // Storage keys
  static const String _userLoggedInKey = 'user_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userDataKey = 'user_data';
  static const String _sessionKey = 'user_session';
  static const String _userTypeKey = 'user_type';
  static const String _lastSyncKey = 'last_sync';

  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    try {
      final response = await _apiService.post('/login', {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        // Save session and user data
        await _saveUserSession(
          sessionId: response['sessionId'],
          userData: response['student'] ?? response['admin'],
          userType: response['student'] != null ? 'student' : 'admin',
        );

        return {
          'success': true,
          'user': response['student'] ?? response['admin'],
          'userType': response['student'] != null ? 'student' : 'admin',
        };
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Email sign in error: $e');
      
      // Fallback to cached credentials for offline access
      final cachedUser = await getCachedUser();
      if (cachedUser != null && cachedUser['email'] == email) {
        return {
          'success': true,
          'user': cachedUser,
          'userType': await _getStoredUserType(),
          'offline': true,
        };
      }
      
      return {
        'success': false,
        'error': 'Network error: $e',
        'offline': true,
      };
    }
  }

  Future<Map<String, dynamic>> signUpWithEmail(String email, String password, Map<String, dynamic> userData) async {
    try {
      // Prepare registration data according to your API
      final registrationData = {
        'student_number': userData['studentNumber'],
        'name': userData['name'],
        'surname': userData['surname'],
        'email': email,
        'password': password,
        'course_id': userData['course'],
        'year_of_study': userData['year'],
        'faculty_id': userData['faculty'],
        'campus_id': userData['campus'],
        'phone_number': userData['phone'],
      };

      final response = await _apiService.post('/register', registrationData);

      if (response['success'] == true) {
        // Store basic user info for immediate access
        await _cacheUserData({
          'email': email,
          'name': '${userData['name']} ${userData['surname']}',
          'student_number': userData['studentNumber'],
          'fullData': registrationData,
        });

        return {
          'success': true,
          'message': 'Registration successful',
          'user': response['student'],
        };
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('Email sign up error: $e');
      
      // Store registration data for offline sync
      await _storePendingRegistration(email, password, userData);
      
      return {
        'success': false,
        'error': 'Network error. Your data will be synced when online.',
        'offline': true,
      };
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser != null) {
        // For Google Sign-In, you might want to create a custom endpoint
        // For now, we'll store locally and sync with your backend
        final userData = {
          'email': googleUser.email,
          'name': googleUser.displayName ?? 'Google User',
          'photoUrl': googleUser.photoUrl,
          'googleId': googleUser.id,
        };

        // Try to register/login with your backend
        try {
          final response = await _apiService.post('/google-auth', {
            'email': googleUser.email,
            'name': googleUser.displayName,
            'google_id': googleUser.id,
          });

          if (response['success'] == true) {
            await _saveUserSession(
              sessionId: response['sessionId'],
              userData: response['user'],
              userType: 'student',
            );
          }
        } catch (apiError) {
          // If backend integration fails, store locally
          print('Google auth API error: $apiError');
          await _cacheUserData(userData);
        }

        return {
          'success': true,
          'user': userData,
          'userType': 'student',
        };
      }
      
      return {
        'success': false,
        'error': 'Google sign in cancelled',
      };
    } catch (e) {
      print('Google sign in error: $e');
      return {
        'success': false,
        'error': 'Google sign in failed: $e',
      };
    }
  }

  Future<void> signOut() async {
    try {
      final sessionId = await getSessionId();
      
      // Call logout API if online and session exists
      if (sessionId != null) {
        try {
          await _apiService.post('/logout', {}, headers: {
            'authorization': sessionId,
          });
        } catch (e) {
          print('Logout API call failed: $e');
          // Continue with local logout even if API fails
        }
      }
      
      // Clear Google sign in
      await _googleSignIn.signOut();
      
      // Clear local storage
      await _clearUserData();
      
      // Clear API service session
      _apiService.clearSessionHeader();
      
    } catch (e) {
      print('Sign out error: $e');
      // Force clear local data even if errors occur
      await _clearUserData();
    }
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString(_sessionKey);
    final userLoggedIn = prefs.getBool(_userLoggedInKey) ?? false;
    
    // Check if session is still valid (you might want to add expiration check)
    return sessionId != null && userLoggedIn;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    
    if (userDataString != null) {
      try {
        return json.decode(userDataString);
      } catch (e) {
        print('Error decoding user data: $e');
      }
    }
    
    // Fallback to legacy storage
    final email = prefs.getString(_userEmailKey);
    final name = prefs.getString(_userNameKey);
    
    if (email != null && name != null) {
      return {
        'email': email,
        'name': name,
      };
    }
    
    return null;
  }

  Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<String?> getUserType() async {
    return await _getStoredUserType();
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      // This would call your backend password reset endpoint
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      return {
        'success': true,
        'message': 'Password reset instructions sent to $email',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to send reset email: $e',
      };
    }
  }

  // Session Management
  Future<void> _saveUserSession({
    required String sessionId,
    required Map<String, dynamic> userData,
    required String userType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Store session ID
    await prefs.setString(_sessionKey, sessionId);
    
    // Store user data
    await prefs.setString(_userDataKey, json.encode(userData));
    
    // Store user type
    await prefs.setString(_userTypeKey, userType);
    
    // Legacy storage for compatibility
    await prefs.setBool(_userLoggedInKey, true);
    await prefs.setString(_userEmailKey, userData['email'] ?? '');
    await prefs.setString(_userNameKey, 
      '${userData['name']} ${userData['surname']}' ?? userData['name'] ?? 'User');
    
    // Set last sync timestamp
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    
    // Set API service session header
    _apiService.setSessionHeader(sessionId);
  }

  // Data Caching for Offline Use
  Future<void> _cacheUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
    await prefs.setBool(_userLoggedInKey, true);
    await prefs.setString(_userEmailKey, userData['email'] ?? '');
    await prefs.setString(_userNameKey, userData['name'] ?? 'User');
  }

  Future<Map<String, dynamic>?> getCachedUser() async {
    return await getCurrentUser();
  }

  // Pending Operations for Offline Sync
  Future<void> _storePendingRegistration(
    String email, 
    String password, 
    Map<String, dynamic> userData
  ) async {
    final prefs = await SharedPreferences.getInstance();
    const pendingKey = 'pending_registration';
    
    await prefs.setString(pendingKey, json.encode({
      'email': email,
      'password': password,
      'userData': userData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }));
    
    // Cache user data for immediate access
    await _cacheUserData({
      'email': email,
      'name': '${userData['name']} ${userData['surname']}',
      'student_number': userData['studentNumber'],
      'pendingSync': true,
    });
  }

  Future<void> syncPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Sync pending registration
    final pendingRegistration = prefs.getString('pending_registration');
    if (pendingRegistration != null) {
      try {
        final data = json.decode(pendingRegistration);
        final result = await signUpWithEmail(
          data['email'],
          data['password'],
          data['userData'],
        );
        
        if (result['success'] == true) {
          await prefs.remove('pending_registration');
        }
      } catch (e) {
        print('Failed to sync pending registration: $e');
      }
    }
    
    // Update last sync timestamp
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Helper Methods
  Future<String?> _getStoredUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all auth-related data
    await prefs.remove(_userLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_sessionKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove('pending_registration');
  }

  // Validation Methods
  bool validateStudentNumber(String studentNumber) {
    return RegExp(r'^\d{9}$').hasMatch(studentNumber);
  }

  bool validateEmail(String email) {
    return RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$').hasMatch(email);
  }

  bool validatePhoneNumber(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone);
  }

  bool validatePassword(String password) {
    return password.length >= 8;
  }

  // Security Methods
  Future<void> clearSensitiveData() async {
    await _clearUserData();
    await _googleSignIn.signOut();
  }

  Future<bool> hasValidSession() async {
    final sessionId = await getSessionId();
    if (sessionId == null) return false;

    // You might want to add session expiration check here
    // For now, we'll consider it valid if it exists
    return true;
  }

  // Profile Management
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await _apiService.put(
        '/students/${profileData['student_number']}',
        profileData,
      );

      if (response['success'] == true) {
        // Update cached user data
        final currentUser = await getCurrentUser();
        if (currentUser != null) {
          await _cacheUserData({...currentUser, ...profileData});
        }
        
        return {
          'success': true,
          'message': 'Profile updated successfully',
          'user': response['student'],
        };
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Profile update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}