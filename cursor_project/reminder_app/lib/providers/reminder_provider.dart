import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:reminder_app/utils/notification_helper.dart';
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

  String get _storageKey =>
      _userId == null ? 'reminders' : 'reminders_${_userId!}';

  Future<void> initDatabase(String? userId) async {
    setUser(userId);
    await scheduleDailySummaryNotifications(); // ✅ 사용자 초기화 시 알림 실행
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
      debugPrint('할 일 로드 완료: ${_reminders.length}개');
    } catch (e) {
      debugPrint('할 일 로드 오류: $e');
      rethrow;
    }
  }

  Future<void> _saveReminders() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList =
      json.encode(_reminders.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, encodedList);
      debugPrint('할 일 저장 완료');
    } catch (e) {
      debugPrint('할 일 저장 오류: $e');
      rethrow;
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    if (_userId == null) return;
    try {
      reminder.id =
          DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
      _reminders.add(reminder);
      await _saveReminders();
      notifyListeners();
      debugPrint('할 일 추가 성공: ID=${reminder.id}');
    } catch (e) {
      debugPrint('할 일 추가 오류: $e');
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
        debugPrint('할 일 업데이트 성공: ID=${reminder.id}');
      }
    } catch (e) {
      debugPrint('할 일 업데이트 오류: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(int id) async {
    if (_userId == null) return;
    try {
      _reminders.removeWhere((r) => r.id == id);
      await _saveReminders();
      notifyListeners();
      debugPrint('할 일 삭제 성공: ID=$id');
    } catch (e) {
      debugPrint('할 일 삭제 오류: $e');
      rethrow;
    }
  }

  Future<void> rescheduleAllReminders(bool enable) async {
    if (!enable) {
      await flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('🔕 모든 알림 취소됨');
      return;
    }

    await scheduleDailySummaryNotifications();
    debugPrint('🔔 하루 3회 리마인더 알림 재예약 완료');
  }

  // ✅ context 없이 사용 가능한 알림 함수 호출
  Future<void> scheduleDailySummaryNotifications() async {
    await scheduleDailyRemindersWithoutContext(this);
  }
}
