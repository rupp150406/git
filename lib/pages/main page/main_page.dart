import 'package:blogin/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:blogin/widgets/custom navbar/custom_navbar.dart';
import 'package:blogin/pages/blog/widget_content.dart';
import '../../services/hive_backend.dart';
import 'package:blogin/widgets/loading/loading.dart';
import 'package:blogin/services/blog_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedCategoryIndex = 0; // 0: For You, 1: Popular, 2: Following
  List<BlogPost> _blogPosts = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _fetchBlogPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  Future<void> _fetchBlogPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch posts from the API using BlogService
      final response = await BlogService.instance.getPosts();
      final postsData = response['data']['data'] as List<dynamic>;

      // Convert API response to BlogPost objects
      final List<BlogPost> posts = [];
      for (var post in postsData) {
        posts.add(
          BlogPost(
            id: post['id'].toString(),
            imagePath:
                post['thumbnail_path'] ?? 'assets/images/default-blog.png',
            category:
                post['categories']?.isNotEmpty
                    ? post['categories'][0]['name']
                    : 'Uncategorized',
            title: post['title'] ?? '',
            author: post['user']['name'] ?? 'Unknown Author',
            authorImage:
                post['user']['picture'] ?? 'assets/images/profile-photo.png',
            timeAgo: _formatDate(post['created_at']),
            content: post['content'] ?? '',
          ),
        );
      }

      setState(() {
        _blogPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching blog posts: $e');
      setState(() {
        _isLoading = false;
        _blogPosts = []; // Empty list on error
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load posts: ${e.toString()}')),
        );
      }
    }
  }

  // Helper method to format date string
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Just now';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month(s) ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day(s) ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour(s) ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute(s) ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  String get _selectedTag {
    switch (_selectedCategoryIndex) {
      case 0:
        return 'For You';
      case 1:
        return 'Popular';
      case 2:
        return 'Following';
      default:
        return 'For You';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredContent = _blogPosts;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:
            _isScrolled ? Colors.white.withOpacity(1.0) : Colors.transparent,
        elevation: _isScrolled ? 1 : 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Blogin',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, searchPageRoute);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child:
            _isLoading
                ? const LoadingVideo()
                : filteredContent.isEmpty
                ? const Center(child: Text('No content available.'))
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: filteredContent.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: WidgetContent(
                        blogPost: filteredContent[index],
                        onDeleted: () {
                          setState(() {
                            _blogPosts.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, blogMakerRoute);
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }

  Widget _buildCategoryButton(String text, int index) {
    final bool isSelected = _selectedCategoryIndex == index;
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans-VariableFont_wght',
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.grey[600],
        ),
      ),
    );
  }
}
