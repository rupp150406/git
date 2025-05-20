import 'package:flutter/material.dart';
import 'package:blogin/services/user_service.dart';
import 'package:blogin/routes/route.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:blogin/widgets/loading/loading.dart';
import 'package:blogin/widgets/custom popup/custom_popup.dart';
import 'package:blogin/pages/profile/save_profile_done_splash.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _profilePhoto;
  String? _existingPhotoUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final response = await UserService.instance.getProfile();
      final userData = response['data']['user'];

      // Handle profile picture URL
      var picturePath = userData['picture'];
      if (picturePath != null &&
          picturePath.isNotEmpty &&
          !picturePath.startsWith('http') &&
          !picturePath.startsWith('assets/')) {
        // Check if it's a relative path starting with '/'
        if (picturePath.startsWith('/')) {
          picturePath = 'https://blogin.faaza-mumtaza.my.id$picturePath';
        } else {
          picturePath = 'https://blogin.faaza-mumtaza.my.id/$picturePath';
        }
      }

      print('Edit Profile - Picture URL: $picturePath');

      setState(() {
        _nameController.text = userData['name'] ?? '';
        _usernameController.text = userData['username'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _bioController.text = userData['bio'] ?? '';
        _existingPhotoUrl = picturePath;
        _isLoading = false;
      });

      // Listen for changes to detect if form is dirty
      _nameController.addListener(_onFieldChanged);
      _usernameController.addListener(_onFieldChanged);
      _emailController.addListener(_onFieldChanged);
      _bioController.addListener(_onFieldChanged);
    } catch (e) {
      print('Error loading profile data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Optimize image size
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _profilePhoto = File(pickedFile.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _usernameController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _bioController.removeListener(_onFieldChanged);

    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show fullscreen loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white, // Make barrier white for fullscreen effect
        builder:
            (context) => WillPopScope(
              onWillPop: () async => false, // Prevent back button dismissal
              child: const Scaffold(
                backgroundColor: Colors.white,
                body: Center(child: LoadingVideo()),
              ),
            ),
      );

      setState(() => _isSaving = true);
      try {
        final response = await UserService.instance.updateProfile(
          name: _nameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          bio: _bioController.text,
          picture: _profilePhoto,
        );

        if (mounted) {
          // Close loading dialog
          Navigator.of(context, rootNavigator: true).pop();

          // Navigate to success splash screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SaveProfileDoneSplashScreen(),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // Close loading dialog
          Navigator.of(context, rootNavigator: true).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: LoadingVideo()),
        backgroundColor: Colors.white,
      );
    }

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black, width: 1.5),
    );

    final labelStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Ask for confirmation if there are unsaved changes
            if (_hasChanges) {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Discard changes?'),
                      content: const Text(
                        'You have unsaved changes. Are you sure you want to discard them?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Discard',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          // Save button in the app bar
          _isSaving
              ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : Container(), // Remove the TextButton
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile photo section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(48),
                          child:
                              _profilePhoto != null
                                  ? Image.file(
                                    _profilePhoto!,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                  )
                                  : _existingPhotoUrl != null
                                  ? CachedNetworkImage(
                                    imageUrl: _existingPhotoUrl!,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => const Icon(
                                          Icons.person,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                  )
                                  : const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: InkWell(
                            onTap: _pickImage,
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Name field
                Text('Name', style: labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: focusedBorder,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Username field
                Text('Username', style: labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: focusedBorder,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    if (value.contains(' ')) {
                      return 'Username cannot contain spaces';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email field
                Text('Email', style: labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: focusedBorder,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Bio field
                Text('Bio', style: labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Write something about yourself',
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    focusedBorder: focusedBorder,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 40),

                // Save and Delete buttons
                Row(
                  children: [
                    // Save button
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _hasChanges && !_isSaving ? _saveProfile : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Delete Account button
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            // Show delete confirmation using CustomPopup
                            showCustomPopup(
                              context,
                              text:
                                  'Are you sure you want to delete your account? This action cannot be undone.',
                              leftButtonText: 'Delete',
                              rightButtonText: 'Cancel',
                              leftButtonOnPressed: () {
                                Navigator.of(context).pop();
                                _deleteAccount();
                              },
                              rightButtonOnPressed: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Delete Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    // Show fullscreen loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white, // Make barrier white for fullscreen effect
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false, // Prevent back button dismissal
            child: const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: LoadingVideo()),
            ),
          ),
    );

    try {
      // Call delete account API
      await UserService.instance.deleteAccount();

      // Navigate to login screen after successful deletion
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // Close loading dialog
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(signInRoute, (route) => false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
