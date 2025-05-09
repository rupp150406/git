import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blogin/widgets/contain navbar/contain_navbar.dart';
import 'package:blogin/services/hive_backend.dart';
import 'category_page.dart';

class BlogMakerPage extends StatefulWidget {
  const BlogMakerPage({Key? key}) : super(key: key);

  @override
  State<BlogMakerPage> createState() => _BlogMakerPageState();
}

class _BlogMakerPageState extends State<BlogMakerPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _imagePath;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveBlog() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final imagePath = _imagePath;
    if (title.isEmpty || content.isEmpty || imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an image.'),
        ),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      final blogPost = await addBlogPost(
        imagePath: imagePath,
        category: 'General', // Default category for now
        title: title,
        content: content,
      );
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryPage(blogPost: blogPost),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save blog: ${e.toString()}')),
      );
    } finally {
      if (mounted)
        setState(() {
          _isSaving = false;
        });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color lightGray = Color(0xFFD3D3D3);
    const Color darkGray = Color(0xFF9E9E9E);
    const double horizontalPadding = 24.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back arrow
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                // Save button
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveBlog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      elevation: 0,
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                fontFamily: 'PlusJakartaSans-VariableFont_wght',
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Title input
              TextFormField(
                controller: _titleController,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  fontFamily: 'PlusJakartaSans-VariableFont_wght',
                ),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    fontFamily: 'PlusJakartaSans-VariableFont_wght',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 18),
              // Static image area with dotted border
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: lightGray,
                      width: 1.5,
                      style:
                          BorderStyle
                              .solid, // Use solid for now; Flutter doesn't support dotted natively
                    ),
                  ),
                  child:
                      _imagePath == null
                          ? Center(
                            child: Icon(
                              Icons.camera_alt,
                              color: darkGray,
                              size: 40,
                            ),
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 180,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 18),
              // Content input
              TextFormField(
                controller: _contentController,
                minLines: 7,
                maxLines: 12,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'PlusJakartaSans-VariableFont_wght',
                ),
                decoration: InputDecoration(
                  hintText: 'type your blog here...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontFamily: 'PlusJakartaSans-VariableFont_wght',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ContainNavBar(),
    );
  }
}
