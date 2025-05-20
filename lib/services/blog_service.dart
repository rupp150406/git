import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:blogin/services/local_backend_service.dart';

class BlogService {
  static const String baseUrl = 'https://blogin.faaza-mumtaza.my.id/api';
  static BlogService? _instance;

  // Singleton pattern
  static BlogService get instance {
    _instance ??= BlogService();
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

  // ============ PUBLIC ENDPOINTS ============

  // Get all published blog posts
  Future<Map<String, dynamic>> getPosts({
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts?per_page=$perPage&page=$page'),
        headers: await _getHeaders(includeAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch posts');
      }
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  // View a specific blog post by ID
  Future<Map<String, dynamic>> getPost(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: await _getHeaders(includeAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch post');
      }
    } catch (e) {
      throw Exception('Failed to fetch post: $e');
    }
  }

  // Search for posts, users, and topics
  Future<Map<String, dynamic>> search(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/search'),
        headers: await _getHeaders(includeAuth: false),
        body: jsonEncode({'q': query}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Search failed');
      }
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // ============ PROTECTED ENDPOINTS ============

  // Get all categories for post creation
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Create a new blog post
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    required List<int> categories,
    File? thumbnail,
    String status = 'published', // default to published
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts'));

      // Add headers
      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // Add text fields
      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['status'] = status;

      // Add categories
      for (int i = 0; i < categories.length; i++) {
        request.fields['categories[$i]'] = categories[i].toString();
      }

      // Add thumbnail if provided
      if (thumbnail != null) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', thumbnail.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to create post');
      }
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Get post data for editing
  Future<Map<String, dynamic>> getPostForEdit(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/edit'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch post for editing');
      }
    } catch (e) {
      throw Exception('Failed to fetch post for editing: $e');
    }
  }

  // Update an existing blog post
  Future<Map<String, dynamic>> updatePost({
    required int postId,
    required String title,
    required String content,
    required List<int> categories,
    File? thumbnail,
    String status = 'published', // default to published
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/posts/$postId'),
      );

      // Add headers
      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // Add text fields
      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['status'] = status;
      request.fields['_method'] =
          'PUT'; // Laravel convention for PUT requests via POST

      // Add categories
      for (int i = 0; i < categories.length; i++) {
        request.fields['categories[$i]'] = categories[i].toString();
      }

      // Add thumbnail if provided
      if (thumbnail != null) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', thumbnail.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update post');
      }
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // Delete a blog post
  Future<Map<String, dynamic>> deletePost(int postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to delete post');
      }
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Upload images for post content
  Future<String> uploadImage(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/posts/upload-image'),
      );

      // Add headers
      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // Add image file
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['url'] as String;
      } else {
        throw Exception(data['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Get user's bookmarked posts
  Future<List<dynamic>> getBookmarks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookmarks'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] ?? [];
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch bookmarks');
      }
    } catch (e) {
      throw Exception('Failed to fetch bookmarks: $e');
    }
  }

  // Add or remove a post from bookmarks
  Future<String> toggleBookmark(int postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookmarks/toggle'),
        headers: await _getHeaders(),
        body: jsonEncode({'post_id': postId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['status'] as String; // 'added' or 'removed'
      } else {
        throw Exception(data['message'] ?? 'Failed to toggle bookmark');
      }
    } catch (e) {
      throw Exception('Failed to toggle bookmark: $e');
    }
  }

  // Get user's notifications
  Future<Map<String, dynamic>> getNotifications({
    int perPage = 10,
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications?per_page=$perPage&page=$page'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch notifications');
      }
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Mark a specific notification as read
  Future<Map<String, dynamic>> markNotificationAsRead(
    int notificationId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(
          data['message'] ?? 'Failed to mark notification as read',
        );
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(
          data['message'] ?? 'Failed to mark all notifications as read',
        );
      }
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Helper method to format blog image URLs
  String formatBlogImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      print('[BlogService] Image URL is null or empty');
      // Return a test image URL for debugging
      return 'https://blogin.faaza-mumtaza.my.id/storage/posts/thumbnails/default.jpg';
    }

    // Debug the original URL
    print('[BlogService] Original image URL: $url');

    // If it's already a full URL, return as is
    if (url.startsWith('http')) {
      print('[BlogService] Already a full URL, returning as is: $url');
      return url;
    }

    // Direct handling for known filename pattern with long random string
    if (url.contains('thumbnails/') && url.length > 30) {
      // This matches patterns like "cnWqCxHLGVM6GFxOjnJZf2s7qYt9DgscrYuEZTF8.jpg"
      final cleanUrl = url.replaceAll(RegExp(r'^/+'), '');
      final formattedUrl = 'https://blogin.faaza-mumtaza.my.id/$cleanUrl';
      print('[BlogService] Direct long filename detected: $formattedUrl');
      return formattedUrl;
    }

    // Check if this is just a filename with long random characters (common pattern from your API)
    final randomFilenamePattern = RegExp(r'^[a-zA-Z0-9]{20,}\.(jpg|jpeg|png)$');
    if (randomFilenamePattern.hasMatch(url)) {
      final formattedUrl =
          'https://blogin.faaza-mumtaza.my.id/storage/posts/thumbnails/$url';
      print('[BlogService] Random filename pattern detected: $formattedUrl');
      return formattedUrl;
    }

    // Special handling for common error cases
    if (url == "1747738649.jpg") {
      // This is likely a profile image, not a blog image
      return 'https://blogin.faaza-mumtaza.my.id/storage/images/profile/1747738649.jpg';
    }

    // Remove any leading slashes
    String cleanUrl = url.replaceAll(RegExp(r'^/+'), '');
    print('[BlogService] Cleaned URL: $cleanUrl');

    String formattedUrl;

    // Path already includes storage/posts/thumbnails
    if (cleanUrl.contains('storage/posts/thumbnails')) {
      formattedUrl = 'https://blogin.faaza-mumtaza.my.id/$cleanUrl';
      print(
        '[BlogService] URL contains thumbnails path, formatted as: $formattedUrl',
      );
    }
    // If it's just a filename without path separators (e.g. "image.jpg")
    else if (!cleanUrl.contains('/')) {
      // Try the direct thumbnails path
      formattedUrl =
          'https://blogin.faaza-mumtaza.my.id/storage/posts/thumbnails/$cleanUrl';
      print('[BlogService] URL is just filename, formatted as: $formattedUrl');
    }
    // If it has some path structure but not the full path
    else {
      // Add domain without assuming full path structure
      formattedUrl = 'https://blogin.faaza-mumtaza.my.id/$cleanUrl';
      print(
        '[BlogService] URL has path but not thumbnails path, formatted as: $formattedUrl',
      );
    }

    print('[BlogService] Final blog image URL: $formattedUrl');

    // Test URL and show results asynchronously (won't affect the return)
    _testUrlStatus(formattedUrl);

    return formattedUrl;
  }

  // Method to test if an image URL is accessible
  Future<bool> testImageUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      print('[BlogService] Image URL test: ${response.statusCode} for $url');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('[BlogService] Error testing image URL: $e for $url');
      return false;
    }
  }

  // Helper to test URL status asynchronously
  void _testUrlStatus(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      print('[BlogService] URL STATUS: ${response.statusCode} - $url');
    } catch (e) {
      print('[BlogService] URL ERROR: $e - $url');
    }
  }
}
