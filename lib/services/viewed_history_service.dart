import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ViewedHistoryService extends ChangeNotifier {
  static final ViewedHistoryService instance = ViewedHistoryService._();
  ViewedHistoryService._();

  static const String _boxName = 'viewed_history';
  static const int _historyLimit = 20;
  Box<Map>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  List<Map<String, dynamic>> get viewedHistory {
    if (_box == null) return [];
    return _box!.values.map((data) => Map<String, dynamic>.from(data)).toList();
  }

  Future<void> addToHistory(Map<String, dynamic> contentData) async {
    if (_box == null) await init();

    // Check if content already exists
    final existingKey = _box!.keys.firstWhere(
      (k) => _box!.get(k)!['id'] == contentData['id'],
      orElse: () => null,
    );

    if (existingKey != null) {
      // If exists, delete old entry
      await _box!.delete(existingKey);
    }

    // Add new entry at the beginning
    await _box!.add(contentData);

    // Remove oldest entries if exceeding limit
    final allKeys = _box!.keys.toList();
    if (allKeys.length > _historyLimit) {
      final keysToRemove = allKeys.sublist(0, allKeys.length - _historyLimit);
      for (var key in keysToRemove) {
        await _box!.delete(key);
      }
    }

    notifyListeners();
  }

  Future<void> clearHistory() async {
    if (_box == null) await init();
    await _box!.clear();
    notifyListeners();
  }

  Future<void> removeItem(String contentId) async {
    if (_box == null) await init();

    final key = _box!.keys.firstWhere(
      (k) => _box!.get(k)!['id'] == contentId,
      orElse: () => null,
    );

    if (key != null) {
      await _box!.delete(key);
      notifyListeners();
    }
  }
}
