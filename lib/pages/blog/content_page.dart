import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/hive_backend.dart';
import '../../services/saved_content_service.dart';
import '../../services/blog_service.dart';
import '../../services/user_service.dart';
import '../../widgets/loading/loading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContentPage extends StatefulWidget {
  final String blogId;
  const ContentPage({Key? key, required this.blogId}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  BlogPost? blogPost;
  Map<String, dynamic>? apiPost;
  bool isLoading = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _fetchBlogPost();
  }

  Future<void> _fetchBlogPost() async {
    try {
      // Fetch post from API
      final response = await BlogService.instance.getPost(
        int.parse(widget.blogId),
      );
      final postData = response['data'];

      print('Fetched blog post data: ${postData['id']}');
      print('Thumbnail path: ${postData['thumbnail_path']}');

      if (mounted) {
        setState(() {
          apiPost = postData;

          // Create a local BlogPost object for compatibility with existing code
          blogPost = BlogPost(
            id: postData['id'].toString(),
            imagePath:
                postData['thumbnail_path'] ?? 'assets/images/default-blog.png',
            category:
                postData['categories']?.isNotEmpty
                    ? postData['categories'][0]['name']
                    : 'Uncategorized',
            title: postData['title'] ?? '',
            author: postData['user']['name'] ?? 'Unknown Author',
            authorImage:
                postData['user']['picture'] ??
                'assets/images/profile-photo.png',
            timeAgo: _formatDate(postData['created_at']),
            content: postData['content'] ?? '',
          );

          print('Blog post created with image path: ${blogPost!.imagePath}');

          isLoading = false;
          if (blogPost != null) {
            _isSaved = SavedContentService.instance.isSaved(blogPost!.id);
          }
        });
      }
    } catch (e) {
      print('Error fetching blog post: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          // Fallback to local storage if API fails
          _fetchLocalBlogPost();
        });
      }
    }
  }

  // Fallback to get from local storage if API fails
  Future<void> _fetchLocalBlogPost() async {
    final post = await getBlogPostById(widget.blogId);
    if (mounted) {
      setState(() {
        blogPost = post;
        if (post != null) {
          _isSaved = SavedContentService.instance.isSaved(post.id);
        }
      });
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
    final String postUrl =
        'https://blogin.faaza-mumtaza.my.id/posts/${widget.blogId}';
    Clipboard.setData(ClipboardData(text: postUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildImage(String? imagePath) {
    // Setup default fallback image
    final defaultImage = Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 60, color: Colors.grey),
      ),
    );

    if (imagePath == null || imagePath.isEmpty) {
      print('[ContentPage] Blog image path is null or empty');
      return defaultImage;
    }

    print('[ContentPage] Building blog image: $imagePath');

    if (imagePath.startsWith('assets/')) {
      print('[ContentPage] Loading from assets: $imagePath');
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('[ContentPage] Error loading asset image: $error');
              return defaultImage;
            },
          ),
        ),
      );
    } else {
      try {
        // Special handling for specific URL pattern from the API
        String url;
        if (imagePath.contains(
              'cnWqCxHLGVM6GFxOjnJZf2s7qYt9DgscrYuEZTF8.jpg',
            ) ||
            RegExp(r'[a-zA-Z0-9]{20,}\.(jpg|jpeg|png)$').hasMatch(imagePath)) {
          // This is the special case for the long random filenames
          url =
              imagePath.startsWith('http')
                  ? imagePath
                  : 'https://blogin.faaza-mumtaza.my.id/storage/posts/thumbnails/${imagePath.split('/').last}';
          print('[ContentPage] Using direct API URL format: $url');
        } else {
          // Standard URL formatting
          url =
              imagePath.startsWith('http')
                  ? imagePath
                  : BlogService.instance.formatBlogImageUrl(imagePath);
          print('[ContentPage] Using standard formatted URL: $url');
        }

        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 500),
          placeholder:
              (context, url) => Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey[400],
                  ),
                ),
              ),
          imageBuilder: (context, imageProvider) {
            print('[ContentPage] Image loaded successfully: $url');
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            );
          },
          errorWidget: (context, url, error) {
            print('[ContentPage] Error loading image: $error');
            print('[ContentPage] Failed URL: $url (Original: $imagePath)');

            // Try a direct hard-coded URL to test connectivity
            final directUrl =
                'https://blogin.faaza-mumtaza.my.id/storage/posts/thumbnails/cnWqCxHLGVM6GFxOjnJZf2s7qYt9DgscrYuEZTF8.jpg';
            print('[ContentPage] Trying direct URL to test: $directUrl');

            // Try a fallback URL
            final fallbackUrl =
                'https://blogin.faaza-mumtaza.my.id/storage/posts/thumbnails/default.jpg';
            print('[ContentPage] Trying fallback URL: $fallbackUrl');

            return Image.network(
              directUrl, // Try the direct URL first
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('[ContentPage] Direct URL also failed: $error');
                return Image.network(
                  fallbackUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('[ContentPage] Fallback also failed: $error');
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      } catch (e) {
        print('[ContentPage] Exception in blog image handling: $e');
        return defaultImage;
      }
    }
  }

  Widget _buildAuthorImage(String? imagePath) {
    // Default author image
    final defaultAuthorImage = const Icon(Icons.person, color: Colors.grey);

    if (imagePath == null || imagePath.isEmpty) {
      return defaultAuthorImage;
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => defaultAuthorImage,
      );
    } else {
      try {
        // Format URL if needed
        final url =
            imagePath.startsWith('http')
                ? imagePath
                : UserService.instance.formatImageUrl(imagePath);

        print('[ContentPage] Author image URL: $url');

        return CachedNetworkImage(
          imageUrl: url,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[400],
              ),
          errorWidget: (context, url, error) {
            print('[ContentPage] Error loading author image: $error');
            return defaultAuthorImage;
          },
        );
      } catch (e) {
        print('[ContentPage] Exception in author image handling: $e');
        return defaultAuthorImage;
      }
    }
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
                ? const Center(child: LoadingVideo())
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
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildImage(blogPost!.imagePath),
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
                            child: _buildAuthorImage(blogPost!.authorImage),
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
                            apiPost != null && apiPost!['views_count'] != null
                                ? '${apiPost!['views_count']} views'
                                : blogPost!.timeAgo,
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
                      Html(
                        data: blogPost!.content,
                        style: {
                          "body": Style(
                            fontSize: FontSize(16),
                            fontFamily: 'PlusJakartaSans-VariableFont_wght',
                            lineHeight: LineHeight(1.5),
                            color: Colors.black,
                          ),
                          "p": Style(padding: HtmlPaddings.only(bottom: 16)),
                          "a": Style(
                            color: Colors.blue,
                            textDecoration: TextDecoration.none,
                          ),
                          "img": Style(
                            width: Width(
                              MediaQuery.of(context).size.width - 40,
                            ),
                            margin: Margins.only(top: 10, bottom: 10),
                          ),
                        },
                        onLinkTap: (url, _, __) {
                          // Handle link taps if needed
                        },
                        extensions: [
                          TagExtension(
                            tagsToExtend: {"img"},
                            builder: (context) {
                              final element = context.element;
                              final attributes = element?.attributes ?? {};
                              final src = attributes['src'] ?? '';

                              if (src.isEmpty) {
                                print(
                                  '[ContentPage] Empty img src in HTML content',
                                );
                                return Container();
                              }

                              print('[ContentPage] HTML img tag src: $src');

                              // Format URL if needed
                              final imageUrl =
                                  src.startsWith('http')
                                      ? src
                                      : BlogService.instance.formatBlogImageUrl(
                                        src,
                                      );

                              print(
                                '[ContentPage] Formatted HTML img URL: $imageUrl',
                              );

                              return CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                fadeInDuration: const Duration(
                                  milliseconds: 500,
                                ),
                                placeholder:
                                    (context, url) => Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                imageBuilder: (context, imageProvider) {
                                  print(
                                    '[ContentPage] HTML image loaded successfully: $imageUrl',
                                  );
                                  return Image(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  );
                                },
                                errorWidget: (context, url, error) {
                                  print(
                                    '[ContentPage] Error loading HTML img: $error',
                                  );
                                  print(
                                    '[ContentPage] Failed URL: $url (Original: $src)',
                                  );

                                  // Try direct URL if it matches the long random filename pattern
                                  if (src.contains(
                                        'cnWqCxHLGVM6GFxOjnJZf2s7qYt9DgscrYuEZTF8.jpg',
                                      ) ||
                                      RegExp(
                                        r'[a-zA-Z0-9]{20,}\.(jpg|jpeg|png)$',
                                      ).hasMatch(src)) {
                                    final directUrl =
                                        'https://blogin.faaza-mumtaza.my.id/storage/posts/thumbnails/${src.split('/').last}';
                                    print(
                                      '[ContentPage] Trying direct HTML img URL: $directUrl',
                                    );

                                    return Image.network(
                                      directUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        print(
                                          '[ContentPage] Direct HTML img URL failed too: $error',
                                        );
                                        // Fallback to default
                                        return _buildHtmlImageFallback();
                                      },
                                    );
                                  }

                                  // Fallback to a hardcoded URL
                                  final fallbackUrl =
                                      'https://blogin.faaza-mumtaza.my.id/storage/posts/thumbnails/default.jpg';
                                  print(
                                    '[ContentPage] Trying HTML img fallback URL: $fallbackUrl',
                                  );

                                  return Image.network(
                                    fallbackUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      print(
                                        '[ContentPage] HTML img fallback also failed: $error',
                                      );
                                      return _buildHtmlImageFallback();
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
      ),
    );
  }

  // Helper method for HTML image fallback
  Widget _buildHtmlImageFallback() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
      ),
    );
  }
}
