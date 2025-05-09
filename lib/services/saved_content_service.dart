import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SavedContentService extends ChangeNotifier {
  static final SavedContentService instance = SavedContentService._();
  SavedContentService._();

  static const String _boxName = 'saved_content';
  Box<Map>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  List<Map<String, dynamic>> get savedContents {
    if (_box == null) return [];
    return _box!.values.map((data) => Map<String, dynamic>.from(data)).toList();
  }

  bool isSaved(String id) {
    if (_box == null) return false;
    return _box!.values.any((content) => content['id'] == id);
  }

  Future<void> toggleSave(String id, Map<String, dynamic> data) async {
    if (_box == null) await init();

    if (isSaved(id)) {
      // Find and delete the content with matching id
      final key = _box!.keys.firstWhere(
        (k) => _box!.get(k)!['id'] == id,
        orElse: () => null,
      );
      if (key != null) {
        await _box!.delete(key);
      }
    } else {
      // Add new content
      await _box!.add(data);
    }
    notifyListeners();
  }

  Future<void> clearAll() async {
    if (_box == null) await init();
    await _box!.clear();
    notifyListeners();
  }
}
