import 'package:blogin/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:blogin/widgets/custom navbar/custom_navbar.dart';
import 'package:blogin/services/local_backend_service.dart'; // Import LocalBackendService
import 'package:blogin/widgets/custom popup/custom_popup.dart';
import '../../services/hive_backend.dart';
import 'package:blogin/pages/blog/widget_content.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTabIndex = 0; // 0: My Blog, 1: About
  String _username = 'Loading...'; // Default value while loading
  String? _profilePhotoPath;
  String _aboutText = 'just a simple person'; // Default about text
  List<BlogPost> _myBlogs = [];
  bool _isLoadingBlogs = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchMyBlogs();
  }

  Future<void> _loadUserData() async {
    final userProfile = await getUserProfile();
    final aboutText = LocalBackendService.instance.getAbout();
    if (userProfile != null) {
      setState(() {
        _username = userProfile.username;
        _profilePhotoPath = userProfile.profilePhotoPath;
        _aboutText = aboutText;
      });
    } else {
      final storedUsername = await LocalBackendService.instance.getUsername();
      if (storedUsername != null) {
        setState(() {
          _username = storedUsername;
          _aboutText = aboutText;
        });
      }
    }
  }

  Future<void> _fetchMyBlogs() async {
    final blogs = await getAllBlogPosts();
    final username = await LocalBackendService.instance.getUsername();
    setState(() {
      _myBlogs = blogs.where((b) => b.author == username).toList();
      _isLoadingBlogs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Stack(
                  children: [
                    // Arrow icon at the top right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.black,
                          size: 23,
                        ),
                        onPressed: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => CustomPopup(
                                  text: 'Are you sure you want to logout?',
                                  leftButtonText: 'Logout',
                                  rightButtonText: 'Cancel',
                                  leftButtonOnPressed:
                                      () => Navigator.of(context).pop(true),
                                  rightButtonOnPressed:
                                      () => Navigator.of(context).pop(false),
                                ),
                          );

                          if (shouldLogout == true && mounted) {
                            // Get username before clearing data
                            final username =
                                await LocalBackendService.instance
                                    .getUsername();

                            // Delete all blogs by this user
                            await deleteAllBlogsByAuthor(username);

                            // Clear all user data
                            await LocalBackendService.instance.clearUserData();
                            // Delete user profile from Hive
                            await deleteUserProfile();

                            if (!mounted) return;

                            // Navigate to sign in and remove all previous routes
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              signInRoute,
                              (route) =>
                                  false, // This removes all previous routes
                            );
                          }
                        },
                      ),
                    ),
                    // Profile info section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.grey[200],
                                child:
                                    _profilePhotoPath != null
                                        ? ClipOval(
                                          child: Image.file(
                                            File(_profilePhotoPath!),
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.person,
                                                      size: 32,
                                                      color: Colors.grey,
                                                    ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.person,
                                          size: 32,
                                          color: Colors.grey,
                                        ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _username,
                                    style: const TextStyle(
                                      fontFamily:
                                          'PlusJakartaSans-VariableFont_wght',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _aboutText,
                                    style: TextStyle(
                                      fontFamily:
                                          'PlusJakartaSans-VariableFont_wght',
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '1 Followers  |  1 Following',
                                    style: TextStyle(
                                      fontFamily:
                                          'PlusJakartaSans-VariableFont_wght',
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: SizedBox(
                            width: 180,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, editProfileRoute);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  0,
                                  0,
                                  0,
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 0,
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontFamily:
                                      'PlusJakartaSans-VariableFont_wght',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTabButton('My Blog', 0),
                            _buildTabButton('About', 1),
                          ],
                        ),
                        const Divider(
                          height: 32,
                          thickness: 1,
                          color: Color(0xFFF2F2F2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    _selectedTabIndex == 0
                        ? (_isLoadingBlogs
                            ? const Center(child: CircularProgressIndicator())
                            : _myBlogs.isEmpty
                            ? const Center(child: Text('No blogs yet.'))
                            : ListView.builder(
                              itemCount: _myBlogs.length,
                              itemBuilder: (context, index) {
                                return WidgetContent(
                                  blogPost: _myBlogs[index],
                                  onDeleted: () {
                                    setState(() {
                                      _myBlogs.removeAt(index);
                                    });
                                  },
                                );
                              },
                            ))
                        : const Center(
                          child: Text(
                            'About section coming soon.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, blogMakerRoute);
          },
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          child: const Icon(Icons.edit),
        ),
        bottomNavigationBar: const CustomNavBar(selectedIndex: 3),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedTabIndex = index;
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
