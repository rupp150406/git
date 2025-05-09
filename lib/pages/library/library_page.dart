import 'package:flutter/material.dart';
import 'package:blogin/widgets/custom navbar/custom_navbar.dart';
import 'package:blogin/services/saved_content_service.dart';
import 'package:blogin/services/viewed_history_service.dart'; // Import ViewedHistoryService
import 'package:blogin/widgets/custom button/custom_button.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:blogin/pages/blog/widget_content.dart';
import '../../services/hive_backend.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _selectedTabIndex = 0; // 0: Saved, 1: History

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

  Widget _buildSavedList() {
    return AnimatedBuilder(
      animation: SavedContentService.instance,
      builder: (context, _) {
        final savedContents = SavedContentService.instance.savedContents;
        if (savedContents.isEmpty) {
          return const Center(
            child: Text(
              'no saved content',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans-VariableFont_wght',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: savedContents.length,
          itemBuilder: (context, index) {
            final content = savedContents[index];
            final blogPost = BlogPost(
              id: content['id'],
              imagePath: content['image'],
              category: content['category'],
              title: content['title'],
              author: content['author'],
              authorImage: content['authorImage'],
              timeAgo: content['time'],
              content: content['content'],
            );
            return WidgetContent(
              blogPost: blogPost,
              onDeleted: () {
                setState(() {});
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryList() {
    return AnimatedBuilder(
      animation: ViewedHistoryService.instance,
      builder: (context, _) {
        final historyContents = ViewedHistoryService.instance.viewedHistory;
        if (historyContents.isEmpty) {
          return const Center(
            child: Text(
              'no viewed history',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans-VariableFont_wght',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: historyContents.length,
          itemBuilder: (context, index) {
            final content = historyContents[index];
            final blogPost = BlogPost(
              id: content['id'],
              imagePath: content['image'] ?? '',
              category: content['category'] ?? '',
              title: content['title'] ?? '',
              author: content['author'] ?? '',
              authorImage: content['authorImage'] ?? '',
              timeAgo: content['time'] ?? '',
              content: content['content'] ?? '',
            );
            return WidgetContent(
              blogPost: blogPost,
              onDeleted: () {
                setState(() {});
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final isSavedTab = _selectedTabIndex == 0;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSavedTab
                      ? 'Are you sure you want to delete all saved content?'
                      : 'Are you sure you want to delete this reading history?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans-VariableFont_wght',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Delete',
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (isSavedTab) {
                            SavedContentService.instance.clearAll();
                          } else {
                            ViewedHistoryService.instance.clearHistory();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomNavBar(selectedIndex: 2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Blogin',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans-VariableFont_wght',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () {
                _showDeleteDialog(context);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabButton('Saved', 0),
                  _buildTabButton('History', 1),
                ],
              ),
            ),
            const Divider(height: 32, thickness: 1, color: Color(0xFFF2F2F2)),
            Expanded(
              child:
                  _selectedTabIndex == 0
                      ? _buildSavedList()
                      : _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }
}
