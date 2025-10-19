// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://jsj-server.onrender.com/api';
  String? _sessionId;

  void setSessionHeader(String sessionId) {
    _sessionId = sessionId;
  }

  void clearSessionHeader() {
    _sessionId = null;
  }

  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = {
      'Content-Type': 'application/json',
      ...?additionalHeaders,
    };

    if (_sessionId != null) {
      headers['authorization'] = _sessionId!;
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (error) {
      return _handleError(error, endpoint);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {Map<String, String>? headers}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(additionalHeaders: headers),
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (error) {
      return _handleError(error, endpoint);
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (error) {
      return _handleError(error, endpoint);
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (error) {
      return _handleError(error, endpoint);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final responseData = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        ...responseData,
      };
    } else {
      return {
        'success': false,
        'error': responseData['error'] ?? 'Request failed with status ${response.statusCode}',
        'statusCode': response.statusCode,
      };
    }
  }

  Map<String, dynamic> _handleError(dynamic error, String endpoint) {
    print('API $endpoint error: $error');
    
    // Try to return cached data if available for GET requests
    if (endpoint.startsWith('GET')) {
      final cachedData = _getCachedData(endpoint);
      if (cachedData != null) {
        return {
          'success': true,
          'cached': true,
          ...cachedData,
        };
      }
    }
    
    return {
      'success': false,
      'error': error.toString(),
      'offline': true,
    };
  }

  // Caching for offline support
  Future<void> _cacheData(String endpoint, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cache_${endpoint.replaceAll('/', '_')}';
    await prefs.setString(cacheKey, json.encode({
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  Map<String, dynamic>? _getCachedData(String endpoint) {
    // This would need to be implemented with async preferences
    // For simplicity, returning null here
    return null;
  }
}