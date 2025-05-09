import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/hive_backend.dart';
import '../../services/saved_content_service.dart';

class ContentPage extends StatefulWidget {
  final String blogId;
  const ContentPage({Key? key, required this.blogId}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  BlogPost? blogPost;
  bool isLoading = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _fetchBlogPost();
  }

  Future<void> _fetchBlogPost() async {
    final post = await getBlogPostById(widget.blogId);
    if (mounted) {
      setState(() {
        blogPost = post;
        isLoading = false;
        if (post != null) {
          _isSaved = SavedContentService.instance.isSaved(post.id);
        }
      });
    }
  }

  void _toggleSave() {
    if (blogPost == null) return;

    setState(() {
      _isSaved = !_isSaved;
      SavedContentService.instance.toggleSave(blogPost!.id, {
        'id': blogPost!.id,
        'image': blogPost!.imagePath,
        'category': blogPost!.category,
        'title': blogPost!.title,
        'author': blogPost!.author,
        'authorImage': blogPost!.authorImage,
        'time': blogPost!.timeAgo,
        'content': blogPost!.content,
      });
    });
  }

  void _handleCopyLink(BuildContext context) {
    const String videoUrl =
        'https://youtube.com/shorts/SXHMnicI6Pg?si=lV0ZgGLx5wPDW2Id';
    Clipboard.setData(const ClipboardData(text: videoUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? Colors.black : Colors.black54,
            ),
            onPressed: _toggleSave,
          ),
          IconButton(
            icon: const Icon(Icons.link, color: Colors.black),
            onPressed: () => _handleCopyLink(context),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : blogPost == null
                ? const Center(child: Text('Blog post not found'))
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        blogPost!.title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 18),
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(blogPost!.imagePath),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Author and time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child:
                                blogPost!.authorImage.startsWith('assets/')
                                    ? Image.asset(
                                      blogPost!.authorImage,
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.file(
                                      File(blogPost!.authorImage),
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                color: Colors.grey,
                                              ),
                                    ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            blogPost!.author,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.visibility,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            blogPost!.timeAgo,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Content
                      Text(
                        blogPost!.content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
      ),
    );
  }
}
