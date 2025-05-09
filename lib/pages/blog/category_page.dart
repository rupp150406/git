import 'package:blogin/routes/route.dart';
import 'package:flutter/material.dart';
import '../../services/hive_backend.dart';
import 'widget_content.dart';
import 'category_option.dart';
import 'publish_option.dart';

class CategoryPage extends StatefulWidget {
  final BlogPost blogPost;

  const CategoryPage({Key? key, required this.blogPost}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late BlogPost _blogPost;
  bool _hasSelectedCategory = false;

  @override
  void initState() {
    super.initState();
    _blogPost = widget.blogPost;
    // Check if the initial category is not the default
    _hasSelectedCategory = _blogPost.category != 'General';
  }

  Future<void> _navigateToTopics() async {
    final selectedCategory = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryOptionPage(blogPost: _blogPost),
      ),
    );

    if (selectedCategory != null && mounted) {
      setState(() {
        _hasSelectedCategory = true;
        _blogPost = BlogPost(
          id: _blogPost.id,
          imagePath: _blogPost.imagePath,
          category: selectedCategory,
          title: _blogPost.title,
          author: _blogPost.author,
          authorImage: _blogPost.authorImage,
          timeAgo: _blogPost.timeAgo,
          content: _blogPost.content,
        );
      });
    }
  }

  Future<void> _navigateToPublication() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublishOptionPage(blogPost: _blogPost),
      ),
    );
  }

  void _showTopicRequiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Choose topic first before save'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Display the blog content using WidgetContent
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: WidgetContent(blogPost: _blogPost),
          ),

          const SizedBox(height: 24),

          // Category options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Topics button
                _buildCategoryButton(
                  context,
                  'Topics',
                  subtitle: _blogPost.category,
                  onPressed: _navigateToTopics,
                ),

                const SizedBox(height: 12),

                // Publication button
                _buildCategoryButton(
                  context,
                  'Publication',
                  subtitle: 'Choose a publication',
                  onPressed: _navigateToPublication,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Save and Publish button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    _hasSelectedCategory
                        ? () {
                          Navigator.pushNamed(context, blogDoneSplashRoute);
                        }
                        : _showTopicRequiredMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save and Publish',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    String text, {
    required VoidCallback onPressed,
    String? subtitle,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 18),
          ],
        ),
      ),
    );
  }
}
