import 'package:blogin/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:blogin/widgets/custom%20button/custom_button.dart';
import 'package:blogin/services/local_backend_service.dart';
import 'package:blogin/services/hive_backend.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserDataForm extends StatefulWidget {
  const UserDataForm({super.key});

  @override
  State<UserDataForm> createState() => _UserDataFormState();
}

class _UserDataFormState extends State<UserDataForm> {
  final TextEditingController _usernameController = TextEditingController();
  String? _selectedImagePath;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _saveUserData() async {
    final username = _usernameController.text.trim();

    // Validate both username and image
    if (username.isEmpty || _selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username and select a profile photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save to LocalBackendService for backward compatibility
      await LocalBackendService.instance.setUsername(username);

      // Save to Hive
      await saveUserProfile(
        username: username,
        profilePhotoPath: _selectedImagePath,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, nameFormDoneSplashRoute);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define consistent text styles
    const String fontFamily =
        'PlusJakartaSans-VariableFont_wght'; // Ensure configured in pubspec.yaml
    final TextStyle titleStyle = const TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    final TextStyle subtitleStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      color: Colors.grey[600],
    );
    final TextStyle labelStyle = const TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );

    // Define input field decoration
    final InputDecoration inputDecoration = InputDecoration(
      hintText: 'Enter your username',
      hintStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        color: Colors.grey[400],
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Text('Your personal data', style: titleStyle),
                const SizedBox(height: 8),
                Text(
                  'Add a profile photo and username before continuing',
                  style: subtitleStyle,
                ),
                const SizedBox(height: 40),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                        ),
                        child:
                            _selectedImagePath != null
                                ? ClipOval(
                                  child: Image.file(
                                    File(_selectedImagePath!),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text('Username', style: labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  decoration: inputDecoration,
                  style: const TextStyle(fontFamily: fontFamily, fontSize: 14),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                            text: 'Continue',
                            onPressed: _saveUserData,
                          ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
