import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/hive_backend.dart';
import '../../services/saved_content_service.dart';
import '../../services/viewed_history_service.dart';
import '../../widgets/custom popup/custom_popup.dart';
import 'content_page.dart';

class WidgetContent extends StatefulWidget {
  final BlogPost blogPost;
  final VoidCallback? onDeleted;
  const WidgetContent({Key? key, required this.blogPost, this.onDeleted})
    : super(key: key);

  @override
  State<WidgetContent> createState() => _WidgetContentState();
}

class _WidgetContentState extends State<WidgetContent> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isSaved = SavedContentService.instance.isSaved(widget.blogPost.id);
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
      SavedContentService.instance.toggleSave(widget.blogPost.id, {
        'id': widget.blogPost.id,
        'image': widget.blogPost.imagePath,
        'category': widget.blogPost.category,
        'title': widget.blogPost.title,
        'author': widget.blogPost.author,
        'authorImage': widget.blogPost.authorImage,
        'time': widget.blogPost.timeAgo,
        'content': widget.blogPost.content,
      });
    });
  }

  void _addToHistory() {
    ViewedHistoryService.instance.addToHistory({
      'id': widget.blogPost.id,
      'image': widget.blogPost.imagePath,
      'category': widget.blogPost.category,
      'title': widget.blogPost.title,
      'author': widget.blogPost.author,
      'authorImage': widget.blogPost.authorImage,
      'time': widget.blogPost.timeAgo,
      'content': widget.blogPost.content,
    });
  }

  String _formatTitleToTwoWords(String title) {
    final words = title.split(' ');
    if (words.length <= 2) {
      return title;
    }
    return '${words[0]} ${words[1]}...';
  }

  void _handleDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => CustomPopup(
            text: 'Are you sure you want to delete this blog?',
            leftButtonText: 'Delete',
            rightButtonText: 'Cancel',
            leftButtonOnPressed: () => Navigator.of(context).pop(true),
            rightButtonOnPressed: () => Navigator.of(context).pop(false),
          ),
    );

    if (shouldDelete == true && mounted) {
      await deleteBlogPost(widget.blogPost.id);
      if (widget.onDeleted != null) {
        widget.onDeleted!();
      }
    }
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
    return GestureDetector(
      onTap: () {
        _addToHistory();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentPage(blogId: widget.blogPost.id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        color: Colors.white,
        child: Container(
          height: 110,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildImage(widget.blogPost.imagePath),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.blogPost.category,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTitleToTwoWords(widget.blogPost.title),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child:
                              widget.blogPost.authorImage.startsWith('assets/')
                                  ? Image.asset(
                                    widget.blogPost.authorImage,
                                    width: 26,
                                    height: 26,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.file(
                                    File(widget.blogPost.authorImage),
                                    width: 26,
                                    height: 26,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                  ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            widget.blogPost.author,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.blogPost.timeAgo,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[500], fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        size: 22,
                      ),
                      onPressed: _toggleSave,
                      splashRadius: 20,
                      color: _isSaved ? Colors.black : Colors.grey[700],
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 22,
                        color: Colors.grey[700],
                      ),
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (String choice) {
                        switch (choice) {
                          case 'copy':
                            _handleCopyLink(context);
                            break;
                          case 'edit':
                            // Edit functionality will be implemented later
                            break;
                          case 'delete':
                            _handleDelete(context);
                            break;
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'copy',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Copy Link',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    try {
      if (imagePath.startsWith('assets/')) {
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: 90,
          height: 90,
          errorBuilder:
              (context, error, stackTrace) => _buildErrorPlaceholder(),
        );
      }

      // Check if file exists before attempting to load it
      final file = File(imagePath);
      if (!file.existsSync()) {
        return _buildErrorPlaceholder();
      }

      return Image.file(
        file,
        fit: BoxFit.cover,
        width: 90,
        height: 90,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    } catch (e) {
      return _buildErrorPlaceholder();
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_rounded, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
