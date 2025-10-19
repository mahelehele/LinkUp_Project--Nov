import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // User preferences
  static Future<void> setUserLoggedIn(bool value) async {
    await _preferences.setBool('isLoggedIn', value);
  }

  static bool isUserLoggedIn() {
    return _preferences.getBool('isLoggedIn') ?? false;
  }

  static Future<void> setUserEmail(String email) async {
    await _preferences.setString('userEmail', email);
  }

  static String getUserEmail() {
    return _preferences.getString('userEmail') ?? '';
  }

  static Future<void> setUserName(String name) async {
    await _preferences.setString('userName', name);
  }

  static String getUserName() {
    return _preferences.getString('userName') ?? '';
  }

  // Student number methods
  static Future<void> setStudentNumber(String studentNumber) async {
    await _preferences.setString('studentNumber', studentNumber);
  }

  static String getStudentNumber() {
    return _preferences.getString('studentNumber') ?? 'N/A';
  }

  // User session data
  static Future<void> setUserSessionId(String sessionId) async {
    await _preferences.setString('sessionId', sessionId);
  }

  static String getUserSessionId() {
    return _preferences.getString('sessionId') ?? '';
  }

  static Future<void> setUserType(String userType) async {
    await _preferences.setString('userType', userType);
  }

  static String getUserType() {
    return _preferences.getString('userType') ?? 'student';
  }

  // Theme preferences
  static Future<void> setDarkMode(bool value) async {
    await _preferences.setBool('isDarkMode', value);
  }

  static bool isDarkMode() {
    return _preferences.getBool('isDarkMode') ?? false;
  }

  // Additional user data
  static Future<void> setUserSurname(String surname) async {
    await _preferences.setString('userSurname', surname);
  }

  static String getUserSurname() {
    return _preferences.getString('userSurname') ?? '';
  }

  static Future<void> setUserCourse(String course) async {
    await _preferences.setString('userCourse', course);
  }

  static String getUserCourse() {
    return _preferences.getString('userCourse') ?? '';
  }

  static Future<void> setUserFaculty(String faculty) async {
    await _preferences.setString('userFaculty', faculty);
  }

  static String getUserFaculty() {
    return _preferences.getString('userFaculty') ?? '';
  }

  static Future<void> setUserCampus(String campus) async {
    await _preferences.setString('userCampus', campus);
  }
  static String getUserCampus() {
    return _preferences.getString('userCampus') ?? '';
  }

  static Future<void> setUserYearOfStudy(String year) async {
    await _preferences.setString('userYearOfStudy', year);
  }

  static String getUserYearOfStudy() {
    return _preferences.getString('userYearOfStudy') ?? '';
  }

  // App preferences
  static Future<void> setFirstLaunch(bool value) async {
    await _preferences.setBool('isFirstLaunch', value);
  }

  static bool isFirstLaunch() {
    return _preferences.getBool('isFirstLaunch') ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    await _preferences.setBool('notificationsEnabled', value);
  }

  static bool areNotificationsEnabled() {
    return _preferences.getBool('notificationsEnabled') ?? true;
  }

  // Clear all user data
  static Future<void> clearUserData() async {
    await _preferences.remove('isLoggedIn');
    await _preferences.remove('userEmail');
    await _preferences.remove('userName');
    await _preferences.remove('studentNumber');
    await _preferences.remove('sessionId');
    await _preferences.remove('userType');
    await _preferences.remove('userSurname');
    await _preferences.remove('userCourse');
    await _preferences.remove('userFaculty');
    await _preferences.remove('userCampus');
    await _preferences.remove('userYearOfStudy');
  }

  // Clear all app data (including preferences)
  static Future<void> clearAllData() async {
    await _preferences.clear();
  }

  // Check if user data exists
  static bool hasUserData() {
    return _preferences.containsKey('userEmail') && 
           _preferences.containsKey('userName') && 
           _preferences.containsKey('studentNumber');
  }

  // Get complete user profile
  static Map<String, String> getUserProfile() {
    return {
      'name': getUserName(),
      'surname': getUserSurname(),
      'email': getUserEmail(),
      'studentNumber': getStudentNumber(),
      'course': getUserCourse(),
      'faculty': getUserFaculty(),
      'campus': getUserCampus(),
      'yearOfStudy': getUserYearOfStudy(),
    };
  }

  // Save complete user profile
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    if (profile['name'] != null) await setUserName(profile['name']);
    if (profile['surname'] != null) await setUserSurname(profile['surname']);
    if (profile['email'] != null) await setUserEmail(profile['email']);
    if (profile['studentNumber'] != null) await setStudentNumber(profile['studentNumber']);
    if (profile['course'] != null) await setUserCourse(profile['course']);
    if (profile['faculty'] != null) await setUserFaculty(profile['faculty']);
    if (profile['campus'] != null) await setUserCampus(profile['campus']);
    if (profile['yearOfStudy'] != null) await setUserYearOfStudy(profile['yearOfStudy']);
  }
}