import 'package:flutter/material.dart';
import 'package:blogin/widgets/custom navbar/custom_navbar.dart';
import 'package:blogin/services/hive_backend.dart';
import 'package:blogin/pages/blog/widget_content.dart';
import 'package:blogin/routes/route.dart';

enum SearchState { initial, suggestions, results }

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  SearchState _currentState = SearchState.initial;
  List<BlogPost> _searchResults = [];
  List<BlogPost> _allBlogPosts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBlogPosts();
  }

  Future<void> _loadBlogPosts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final posts = await getAllBlogPosts();
      setState(() {
        _allBlogPosts = posts;
      });
    } catch (e) {
      // Handle error if needed
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _searchResults.clear();
        _currentState = SearchState.initial;
      } else {
        _searchResults = _performSearch(value);
        _currentState =
            _searchResults.isNotEmpty
                ? SearchState.results
                : SearchState.suggestions;
      }
    });
  }

  List<BlogPost> _performSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return _allBlogPosts.where((post) {
      return post.title.toLowerCase().contains(lowerQuery) ||
          post.category.toLowerCase().contains(lowerQuery) ||
          post.author.toLowerCase().contains(lowerQuery) ||
          post.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Widget _buildInitialUI() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Text(
        'Start searching...',
        style: TextStyle(
          color: Colors.grey[500],
          fontFamily: 'PlusJakartaSans-VariableFont_wght',
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSuggestionsUI() {
    final input = _searchController.text;
    final suggestions = [
      'Search in "$input" category',
      'Search for "$input" in titles',
      'Search for author "$input"',
    ];
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.search, color: Colors.black54),
          title: Text(
            suggestions[index],
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans-VariableFont_wght',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          onTap: () => _onSearchChanged(input),
        );
      },
    );
  }

  Widget _buildResultsUI() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No results found.',
          style: TextStyle(
            color: Colors.grey[500],
            fontFamily: 'PlusJakartaSans-VariableFont_wght',
            fontSize: 16,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: WidgetContent(blogPost: _searchResults[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomNavBar(selectedIndex: 1),
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
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
              child: TextFormField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search blogs...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontFamily: 'PlusJakartaSans-VariableFont_wght',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.black54,
                    size: 24,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFF5F5F5),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFF5F5F5),
                      width: 1.0,
                    ),
                  ),
                  isCollapsed: true,
                ),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans-VariableFont_wght',
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child:
                  _currentState == SearchState.initial
                      ? _buildInitialUI()
                      : _currentState == SearchState.suggestions
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildSuggestionsUI(),
                      )
                      : _buildResultsUI(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, blogMakerRoute);
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
