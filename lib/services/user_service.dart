import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:blogin/services/local_backend_service.dart';

class UserService {
  static const String baseUrl = 'https://blogin.faaza-mumtaza.my.id/api';
  static UserService? _instance;

  // Singleton pattern
  static UserService get instance {
    _instance ??= UserService();
    return _instance!;
  }

  // Get auth token from LocalBackendService
  Future<String?> _getAuthToken() async {
    return await LocalBackendService.instance.getToken();
  }

  // Helper method to create headers with auth token
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Get username from profile
  Future<String?> getUsername() async {
    try {
      final response = await getProfile();
      return response['data']['user']['username'];
    } catch (e) {
      return null;
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(includeAuth: false),
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save token to LocalBackendService
        if (data['data']['token'] != null) {
          await LocalBackendService.instance.setToken(data['data']['token']);
        }
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(includeAuth: false),
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Print response for debugging
      print('Login response status: ${response.statusCode}');

      // Parse response safely
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        // If JSON parsing fails, create a friendly error
        print('Error parsing login response: $e');
        print('Response body: ${response.body}');
        throw Exception(
          'Unable to connect to the server. Please try again later.',
        );
      }

      if (response.statusCode == 200) {
        // Save token to LocalBackendService
        if (data['data'] != null && data['data']['token'] != null) {
          await LocalBackendService.instance.setToken(data['data']['token']);
        }
        return data;
      } else {
        // Check for known error patterns
        if (response.body.contains('Dedoc\\Scramble\\Scramble') ||
            response.body.contains('not found')) {
          throw Exception(
            'Unable to connect to the server. Please try again later.',
          );
        }
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      // Filter out specific technical errors
      if (e.toString().contains('Dedoc\\Scramble\\Scramble') ||
          e.toString().contains('not found')) {
        throw Exception(
          'Unable to connect to the server. Please try again later.',
        );
      }
      throw Exception('Failed to login: $e');
    }
  }

  // Get public user profile
  Future<Map<String, dynamic>> getPublicProfile(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$username'),
        headers: await _getHeaders(includeAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Format image URL if needed
        if (data['data'] != null &&
            data['data']['user'] != null &&
            data['data']['user']['picture'] != null) {
          final picturePath = data['data']['user']['picture'];
          data['data']['user']['picture'] = _formatImageUrl(picturePath);
        }
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Failed to get public profile: $e');
    }
  }

  // Get authenticated user's profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Format image URL if needed
        if (data['data'] != null &&
            data['data']['user'] != null &&
            data['data']['user']['picture'] != null) {
          final picturePath = data['data']['user']['picture'];
          data['data']['user']['picture'] = _formatImageUrl(picturePath);
        }
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Helper method to format image URLs
  String _formatImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }

    // Debug the original URL
    print('Original image URL: $url');

    // If it's already a full URL, return as is
    if (url.startsWith('http')) {
      print('URL already contains http, returning as is: $url');
      return url;
    }

    String formattedUrl;

    // Handle profile image URLs specifically
    if (url.contains('profile/')) {
      formattedUrl =
          'https://blogin.faaza-mumtaza.my.id/storage/images/profile/$url';
    }
    // If it's just a filename for profile photo
    else if (!url.contains('/')) {
      formattedUrl =
          'https://blogin.faaza-mumtaza.my.id/storage/images/profile/$url';
    }
    // Handle storage URLs
    else if (url.contains('storage/') || url.contains('/storage/')) {
      // Strip any leading slashes and ensure correct format
      final cleanPath = url.replaceAll(RegExp(r'^/+'), '');
      formattedUrl = 'https://blogin.faaza-mumtaza.my.id/$cleanPath';
    }
    // Add base URL for other relative paths
    else if (url.startsWith('/')) {
      formattedUrl = 'https://blogin.faaza-mumtaza.my.id$url';
    } else {
      formattedUrl = 'https://blogin.faaza-mumtaza.my.id/$url';
    }

    print('Formatted image URL: $formattedUrl');
    return formattedUrl;
  }

  // Public method to format image URLs
  String formatImageUrl(String? url) {
    return _formatImageUrl(url);
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? username,
    String? email,
    String? bio,
    File? picture,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/profile'),
      );

      // Add headers
      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // Add text fields
      if (name != null) request.fields['name'] = name;
      if (username != null) request.fields['username'] = username;
      if (email != null) request.fields['email'] = email;
      if (bio != null) request.fields['bio'] = bio;

      // Add picture if provided
      if (picture != null) {
        request.files.add(
          await http.MultipartFile.fromPath('picture', picture.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Delete user account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/profile'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Clear token from LocalBackendService
        await LocalBackendService.instance.setToken(null);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Follow user
  Future<Map<String, dynamic>> followUser(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/follow/$userId'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to follow user');
      }
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  // Unfollow user
  Future<Map<String, dynamic>> unfollowUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/follow/$userId'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to unfollow user');
      }
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  // Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Clear token from LocalBackendService
        await LocalBackendService.instance.setToken(null);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to logout');
      }
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  // Get user followers
  Future<List<dynamic>> getFollowers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/followers'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data']['followers'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Failed to get followers');
      }
    } catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  // Get users the current user is following
  Future<List<dynamic>> getFollowing() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/following'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data']['following'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Failed to get following');
      }
    } catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }
}
