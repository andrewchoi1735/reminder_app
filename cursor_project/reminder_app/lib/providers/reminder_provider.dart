import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reminder.dart';

class ReminderProvider with ChangeNotifier {
  List<Reminder> _reminders = [];
  String? _userId;

  List<Reminder> get reminders => _reminders;
  String? get userId => _userId;

  void setUser(String? userId) {
    _userId = userId;
    loadReminders();
  }

  String get _storageKey => _userId == null ? 'reminders' : 'reminders_${_userId!}';

  Future<void> initDatabase(String? userId) async {
    setUser(userId);
  }

  Future<void> loadReminders() async {
    if (_userId == null) {
      _reminders = [];
      notifyListeners();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? remindersJson = prefs.getString(_storageKey);
      if (remindersJson != null) {
        final List<dynamic> decodedList = json.decode(remindersJson);
        _reminders = decodedList.map((item) => Reminder.fromJson(item)).toList();
      } else {
        _reminders = [];
      }
      notifyListeners();
      debugPrint('리마인더 로드 완료: ${_reminders.length}개');
    } catch (e) {
      debugPrint('리마인더 로드 오류: $e');
      rethrow;
    }
  }

  Future<void> _saveReminders() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = json.encode(_reminders.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, encodedList);
      debugPrint('리마인더 저장 완료');
    } catch (e) {
      debugPrint('리마인더 저장 오류: $e');
      rethrow;
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    if (_userId == null) return;
    try {
      reminder.id = DateTime.now().millisecondsSinceEpoch;
      _reminders.add(reminder);
      await _saveReminders();
      notifyListeners();
      debugPrint('리마인더 추가 성공: ID=${reminder.id}');
    } catch (e) {
      debugPrint('리마인더 추가 오류: $e');
      rethrow;
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    if (_userId == null) return;
    try {
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = reminder;
        await _saveReminders();
        notifyListeners();
        debugPrint('리마인더 업데이트 성공: ID=${reminder.id}');
      }
    } catch (e) {
      debugPrint('리마인더 업데이트 오류: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(int id) async {
    if (_userId == null) return;
    try {
      _reminders.removeWhere((r) => r.id == id);
      await _saveReminders();
      notifyListeners();
      debugPrint('리마인더 삭제 성공: ID=$id');
    } catch (e) {
      debugPrint('리마인더 삭제 오류: $e');
      rethrow;
    }
  }
} 