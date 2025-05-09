import 'package:flutter/material.dart';

class ViewedHistoryService extends ChangeNotifier {
  static final ViewedHistoryService instance = ViewedHistoryService._();
  ViewedHistoryService._();

  final List<Map<String, dynamic>> _viewedContents = [];
  static const int _historyLimit = 20; // Batas jumlah item riwayat

  List<Map<String, dynamic>> get viewedHistory => _viewedContents;

  void addToHistory(Map<String, dynamic> contentData) {
    // Cek apakah konten sudah ada di riwayat (mungkin berdasarkan ID)
    final existingIndex = _viewedContents.indexWhere(
      (item) => item['id'] == contentData['id'],
    );

    if (existingIndex != -1) {
      // Jika sudah ada, pindahkan ke bagian atas (terakhir dilihat)
      final existingItem = _viewedContents.removeAt(existingIndex);
      _viewedContents.insert(0, existingItem);
    } else {
      // Jika belum ada, tambahkan ke bagian atas
      _viewedContents.insert(0, contentData);
      // Jika melebihi batas, hapus item terlama
      if (_viewedContents.length > _historyLimit) {
        _viewedContents.removeLast();
      }
    }
    notifyListeners();
  }

  void clearHistory() {
    _viewedContents.clear();
    notifyListeners();
  }

  void removeItem(String contentId) {
    _viewedContents.removeWhere((item) => item['id'] == contentId);
    notifyListeners();
  }
}
