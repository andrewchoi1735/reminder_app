import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';

class LedgerProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  String? _userId;

  List<Transaction> get transactions {
    final copy = List<Transaction>.from(_transactions);
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  int get incomeTotal => _transactions
      .where((tx) => tx.type == 'income')
      .fold(0, (sum, tx) => sum + tx.amount);

  int get expenseTotal => _transactions
      .where((tx) => tx.type == 'expense')
      .fold(0, (sum, tx) => sum + tx.amount);

  void setUser(String? userId) {
    _userId = userId;
    loadTransactions();
  }

  String get _storageKey =>
      _userId == null ? 'ledger' : 'ledger_${_userId!}';

  Future<void> loadTransactions() async {
    if (_userId == null) {
      _transactions = [];
      notifyListeners();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? ledgerJson = prefs.getString(_storageKey);
      if (ledgerJson != null) {
        final List<dynamic> decodedList = json.decode(ledgerJson);
        _transactions = decodedList
            .map((item) => Transaction.fromJson(item))
            .toList();
      } else {
        _transactions = [];
      }
      notifyListeners();
      debugPrint('가계부 로드 완료: ${_transactions.length}개');
    } catch (e) {
      debugPrint('가계부 로드 오류: $e');
      rethrow;
    }
  }

  Future<void> _saveTransactions() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList =
      json.encode(_transactions.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, encodedList);
      debugPrint('가계부 저장 완료');
    } catch (e) {
      debugPrint('가계부 저장 오류: $e');
      rethrow;
    }
  }

  Future<void> addTransaction(Transaction tx) async {
    if (_userId == null) return;
    try {
      tx = tx.copyWith(id: DateTime.now().millisecondsSinceEpoch);
      _transactions.add(tx);
      await _saveTransactions();
      notifyListeners();
      debugPrint('가계부 항목 추가: ID=${tx.id}');
    } catch (e) {
      debugPrint('가계부 항목 추가 오류: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    if (_userId == null) return;
    try {
      _transactions.removeWhere((t) => t.id == id);
      await _saveTransactions();
      notifyListeners();
      debugPrint('가계부 항목 삭제: ID=$id');
    } catch (e) {
      debugPrint('가계부 항목 삭제 오류: $e');
      rethrow;
    }
  }

  Future<void> clearAll() async {
    if (_userId == null) return;
    _transactions.clear();
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction tx) async {
    if (_userId == null) return;
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      _transactions[index] = tx;
      await _saveTransactions();
      notifyListeners();
    }
  }
}
