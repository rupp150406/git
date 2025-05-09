import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
part 'hive_backend.g.dart'; // Run build_runner after creating this file

// Name of the Hive boxes
const String _blogBoxName = 'blogs';
const String _userProfileBoxName = 'user_profile';

// Function to initialize Hive for blog storage
Future<void> initializeHiveForBlog() async {
  final directory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(
    BlogPostAdapter(),
  ); // Run build_runner after creating this file
  Hive.registerAdapter(UserProfileAdapter());
}

// User Profile data model
@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String? profilePhotoPath;

  UserProfile({required this.username, this.profilePhotoPath});
}

// Open the user profile box
Future<Box<UserProfile>> _openUserProfileBox() async {
  return await Hive.openBox<UserProfile>(_userProfileBoxName);
}

// Save user profile
Future<void> saveUserProfile({
  required String username,
  String? profilePhotoPath,
}) async {
  final box = await _openUserProfileBox();
  final profile = UserProfile(
    username: username,
    profilePhotoPath: profilePhotoPath,
  );
  await box.put('current_user', profile);
}

// Get user profile
Future<UserProfile?> getUserProfile() async {
  final box = await _openUserProfileBox();
  return box.get('current_user');
}

// Delete user profile
Future<void> deleteUserProfile() async {
  final box = await _openUserProfileBox();
  await box.delete('current_user');
}

// BlogPost data model
@HiveType(typeId: 0)
class BlogPost extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String imagePath;

  @HiveField(2)
  String category;

  @HiveField(3)
  String title;

  @HiveField(4)
  String author;

  @HiveField(5)
  String authorImage;

  @HiveField(6)
  String timeAgo;

  @HiveField(7)
  String content;

  BlogPost({
    required this.id,
    required this.imagePath,
    required this.category,
    required this.title,
    required this.author,
    required this.authorImage,
    required this.timeAgo,
    required this.content,
  });
}

// Open the blog box
Future<Box<BlogPost>> _openBlogBox() async {
  return await Hive.openBox<BlogPost>(_blogBoxName);
}

// Add a new blog post
Future<BlogPost> addBlogPost({
  required String imagePath,
  required String category,
  required String title,
  required String content,
}) async {
  final box = await _openBlogBox();
  final prefs = await SharedPreferences.getInstance();
  final author = prefs.getString('username') ?? 'Anonymous';
  final id = DateTime.now().millisecondsSinceEpoch.toString();
  final now = DateTime.now();
  final timeAgo = _calculateTimeAgo(now);

  // Get the user's profile photo
  final userProfile = await getUserProfile();
  final authorImage =
      userProfile?.profilePhotoPath ?? 'assets/images/profile-photo.png';

  final newPost = BlogPost(
    id: id,
    imagePath: imagePath,
    category: category,
    title: title,
    author: author,
    authorImage: authorImage,
    timeAgo: timeAgo,
    content: content,
  );

  await box.add(newPost);
  return newPost;
}

// Get all blog posts
Future<List<BlogPost>> getAllBlogPosts() async {
  final box = await _openBlogBox();
  return box.values.toList();
}

// Get a blog post by ID
Future<BlogPost?> getBlogPostById(String id) async {
  final box = await _openBlogBox();
  try {
    return box.values.firstWhere((post) => post.id == id);
  } catch (_) {
    return null;
  }
}

// Update a blog post
Future<void> updateBlogPost({
  required String id,
  String? imagePath,
  String? category,
  String? title,
  String? content,
}) async {
  final box = await _openBlogBox();
  final index = box.values.toList().indexWhere((post) => post.id == id);
  if (index != -1) {
    final existingPost = box.getAt(index);
    if (existingPost != null) {
      final updatedPost = BlogPost(
        id: id,
        imagePath: imagePath ?? existingPost.imagePath,
        category: category ?? existingPost.category,
        title: title ?? existingPost.title,
        author: existingPost.author,
        authorImage: existingPost.authorImage,
        timeAgo: existingPost.timeAgo,
        content: content ?? existingPost.content,
      );
      await box.putAt(index, updatedPost);
    }
  }
}

// Delete a blog post by ID
Future<void> deleteBlogPost(String id) async {
  final box = await _openBlogBox();
  final index = box.values.toList().indexWhere((post) => post.id == id);
  if (index != -1) {
    await box.deleteAt(index);
  }
}

// Delete all blog posts by author
Future<void> deleteAllBlogsByAuthor(String author) async {
  final box = await _openBlogBox();

  try {
    // Get all posts and their keys
    final posts = box.values.toList();
    final keys = box.keys.toList();

    // Find all posts by this author and delete them
    for (var i = 0; i < posts.length; i++) {
      if (posts[i].author == author) {
        await box.delete(keys[i]);
      }
    }

    // Close the box after operation
    await box.compact(); // Remove deleted entries
    await box.close();
  } catch (e) {
    print('Error deleting blogs: $e');
    // Make sure box is closed even if there's an error
    await box.close();
    rethrow;
  }
}

// Private function to calculate time ago
String _calculateTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return '1 day ago';
  } else {
    return '${difference.inDays} days ago';
  }
}
