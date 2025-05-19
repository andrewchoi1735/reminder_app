import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/memo.dart';

class MemoProvider with ChangeNotifier {
  List<Memo> _memos = [];
  String? _userId;

  List<Memo> get memos => _memos;
  String? get userId => _userId;

  void setUser(String? userId) {
    _userId = userId;
    loadMemos();
  }

  String get _storageKey => _userId == null ? 'memos' : 'memos_${_userId!}';

  Future<void> loadMemos() async {
    if (_userId == null) {
      _memos = [];
      notifyListeners();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? memosJson = prefs.getString(_storageKey);
      if (memosJson != null) {
        final List<dynamic> decodedList = json.decode(memosJson);
        _memos = decodedList.map((item) => Memo.fromJson(item)).toList();
      } else {
        _memos = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('메모 로드 오류: $e');
      rethrow;
    }
  }

  Future<void> _saveMemos() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = json.encode(_memos.map((m) => m.toJson()).toList());
      await prefs.setString(_storageKey, encodedList);
    } catch (e) {
      debugPrint('메모 저장 오류: $e');
      rethrow;
    }
  }

  Future<void> addMemo(Memo memo) async {
    if (_userId == null) return;
    try {
      memo.id = DateTime.now().millisecondsSinceEpoch;
      _memos.insert(0, memo);
      await _saveMemos();
      notifyListeners();
    } catch (e) {
      debugPrint('메모 추가 오류: $e');
      rethrow;
    }
  }

  Future<void> updateMemo(Memo memo) async {
    if (_userId == null) return;
    try {
      final index = _memos.indexWhere((m) => m.id == memo.id);
      if (index != -1) {
        _memos[index] = memo;
        await _saveMemos();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('메모 수정 오류: $e');
      rethrow;
    }
  }

  Future<void> deleteMemo(int id) async {
    if (_userId == null) return;
    try {
      _memos.removeWhere((m) => m.id == id);
      await _saveMemos();
      notifyListeners();
    } catch (e) {
      debugPrint('메모 삭제 오류: $e');
      rethrow;
    }
  }
} 