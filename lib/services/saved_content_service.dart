import 'package:flutter/material.dart';

class SavedContentService extends ChangeNotifier {
  static final SavedContentService instance = SavedContentService._();
  SavedContentService._();

  final Set<String> _savedContentIds = {};
  final Map<String, Map<String, dynamic>> _contentData = {};

  List<Map<String, dynamic>> get savedContents =>
      _savedContentIds.map((id) => _contentData[id]!).toList();

  bool isSaved(String id) => _savedContentIds.contains(id);

  void toggleSave(String id, Map<String, dynamic> data) {
    if (_savedContentIds.contains(id)) {
      _savedContentIds.remove(id);
    } else {
      _savedContentIds.add(id);
      _contentData[id] = data;
    }
    notifyListeners();
  }

  void clearAll() {
    _savedContentIds.clear();
    _contentData.clear();
    notifyListeners();
  }
}
