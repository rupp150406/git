import 'package:blogin/routes/route.dart';
import 'package:flutter/material.dart';
import '../../services/hive_backend.dart';

class PublishOptionPage extends StatefulWidget {
  final BlogPost blogPost;

  const PublishOptionPage({Key? key, required this.blogPost}) : super(key: key);

  @override
  State<PublishOptionPage> createState() => _PublishOptionPageState();
}

class _PublishOptionPageState extends State<PublishOptionPage> {
  String _selectedOption = 'No publication'; // Default selection

  final List<String> _options = ['Publication', 'No publication'];

  void _handleSave() {
    if (_selectedOption == 'Publication') {
      // Show message that publish feature is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publish feature is not available'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Navigate to category page if "No publication" is selected
      Navigator.pushNamedAndRemoveUntil(
        context,
        categoryPageRoute,
        (route) => false,
        arguments: widget.blogPost,
      );
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a publication',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You must complete the submission process in order for your blog to be sent to the publication\'s editor. The editor will be responsible for publishing your draft.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _options.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final option = _options[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RadioListTile<String>(
                    title: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: option,
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedOption = value;
                        });
                      }
                    },
                    activeColor: Colors.black,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save',
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
}
