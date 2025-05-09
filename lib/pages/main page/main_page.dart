import 'package:blogin/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:blogin/widgets/custom navbar/custom_navbar.dart';
import 'package:blogin/pages/blog/widget_content.dart';
import '../../services/hive_backend.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedCategoryIndex = 0; // 0: For You, 1: Popular, 2: Following
  List<BlogPost> _blogPosts = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _fetchBlogPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  Future<void> _fetchBlogPosts() async {
    final posts = await getAllBlogPosts();
    setState(() {
      _blogPosts = posts;
      _isLoading = false;
    });
  }

  String get _selectedTag {
    switch (_selectedCategoryIndex) {
      case 0:
        return 'For You';
      case 1:
        return 'Popular';
      case 2:
        return 'Following';
      default:
        return 'For You';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredContent = _blogPosts;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:
            _isScrolled ? Colors.white.withOpacity(1.0) : Colors.transparent,
        elevation: _isScrolled ? 1 : 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Blogin',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, searchPageRoute);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredContent.isEmpty
                ? const Center(child: Text('No content available.'))
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: filteredContent.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: WidgetContent(
                        blogPost: filteredContent[index],
                        onDeleted: () {
                          setState(() {
                            _blogPosts.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }

  Widget _buildCategoryButton(String text, int index) {
    final bool isSelected = _selectedCategoryIndex == index;
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedCategoryIndex = index;
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
