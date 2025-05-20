import 'package:blogin/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:blogin/widgets/custom navbar/custom_navbar.dart';
import 'package:blogin/services/user_service.dart';
import 'package:blogin/widgets/custom popup/custom_popup.dart';
import '../../services/hive_backend.dart';
import 'package:blogin/pages/blog/widget_content.dart';
import 'package:blogin/widgets/loading/loading.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  Map<String, dynamic>? _userData;
  List<dynamic> _myBlogs = [];
  bool _isLoadingBlogs = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
    _fetchMyBlogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await UserService.instance.getProfile();
      print('Full API Response: $response');

      var userData = response['data']['user'];
      print('User data: $userData');
      print('Picture URL: ${userData['picture']}');

      // Debug the raw picture value
      if (userData['picture'] != null) {
        print('Raw picture value type: ${userData['picture'].runtimeType}');
        print('Raw picture value: ${userData['picture']}');

        // Test the image URL directly
        _testImageUrl(userData['picture']);
      }

      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testImageUrl(String url) async {
    try {
      print('Testing image URL: $url');
      final response = await http.get(Uri.parse(url));
      print('Image URL status code: ${response.statusCode}');
      print('Image URL content type: ${response.headers['content-type']}');
      print('Image URL content length: ${response.contentLength}');
    } catch (e) {
      print('Error testing image URL: $e');
    }
  }

  Future<void> _fetchMyBlogs() async {
    try {
      final username = await UserService.instance.getUsername();
      if (username != null) {
        final response = await UserService.instance.getPublicProfile(username);
        setState(() {
          _myBlogs = response['data']['user']['posts'] ?? [];
          _isLoadingBlogs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      setState(() => _isLoadingBlogs = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: LoadingVideo()),
      );
    }

    if (_userData == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Failed to load profile')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              // Logout functionality
              showCustomPopup(
                context,
                text: 'Are you sure you want to log out?',
                leftButtonText: 'Logout',
                rightButtonText: 'Cancel',
                leftButtonOnPressed: () async {
                  Navigator.of(context).pop(); // Close popup
                  _logout();
                },
                rightButtonOnPressed: () {
                  Navigator.of(context).pop(); // Close popup
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                // Profile Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child:
                        _userData!['picture'] != null &&
                                _userData!['picture'].toString().isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: _userData!['picture'],
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              placeholder:
                                  (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                              errorWidget: (context, url, error) {
                                print('Failed to load profile image: $error');
                                print('Attempted URL: $url');

                                // Try direct Image.network as fallback
                                return Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Fallback also failed: $error');
                                    return const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey,
                                    );
                                  },
                                );
                              },
                            )
                            : const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                  ),
                ),
                const SizedBox(height: 12),

                // Name
                Text(
                  _userData!['name'] ?? 'User Name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Followers count
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${_userData!['followers_count'] ?? 0} Followers · ${_userData!['followees_count'] ?? 0} Following',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Edit Profile Button
                SizedBox(
                  width: 200,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, editProfileRoute).then((_) {
                        // Refresh data when returning from edit profile
                        _loadUserProfile();
                        _fetchMyBlogs();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                    child: const Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black12, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [Tab(text: 'My Blog'), Tab(text: 'About')],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // My Blog Tab
                _isLoadingBlogs
                    ? const Center(child: LoadingVideo())
                    : _myBlogs.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No blog posts yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _myBlogs.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final blog = _myBlogs[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (blog['title'] != null)
                                  Text(
                                    blog['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                if (blog['content'] != null)
                                  Text(
                                    blog['content'],
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      blog['created_at'] != null
                                          ? 'Posted on ${blog['created_at'].toString().split('T')[0]}'
                                          : '',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.favorite_border,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text('${blog['likes_count'] ?? 0}'),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.comment_outlined,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text('${blog['comments_count'] ?? 0}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                // About Tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData!['bio'] != null &&
                                  _userData!['bio'].toString().isNotEmpty
                              ? _userData!['bio']
                              : 'No bio yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button for creating new posts
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, blogMakerRoute);
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.edit, color: Colors.white),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: const CustomNavBar(selectedIndex: 3),
    );
  }

  Future<void> _logout() async {
    try {
      // Show fullscreen loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white,
        builder:
            (context) => WillPopScope(
              onWillPop: () async => false,
              child: const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: LoadingVideo()),
              ),
            ),
      );

      // Call logout API
      await UserService.instance.logout();

      // Navigate to login screen
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // Close loading dialog
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(signInRoute, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout: ${e.toString()}')),
        );
      }
    }
  }
}
