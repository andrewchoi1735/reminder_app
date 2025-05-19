import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:math' as math;

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('계산기'),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFF3D1),
      body: const _BasicCalculatorView(),
    );
  }
}

class _BasicCalculatorView extends StatefulWidget {
  const _BasicCalculatorView({Key? key}) : super(key: key);
  @override
  State<_BasicCalculatorView> createState() => _BasicCalculatorViewState();
}

class _BasicCalculatorViewState extends State<_BasicCalculatorView> {
  String _expression = '';
  String _result = '';
  List<String> _history = [];

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        try {
          final res = _calculate(_expression);
          _result = res;
          if (_expression.isNotEmpty) {
            _history.insert(0, '$_expression = $_result');
            if (_history.length > 20) _history = _history.sublist(0, 20);
          }
        } catch (e) {
          _result = '오류';
        }
      } else {
        _expression += value;
      }
    });
  }

  String _calculate(String expr) {
    try {
      String sanitized = expr.replaceAll('×', '*').replaceAll('÷', '/');
      final tokens = RegExp(r'([\d.]+|[+\-*/])').allMatches(sanitized).map((m) => m.group(0)!).toList();
      if (tokens.isEmpty) return '';
      double total = double.parse(tokens[0]!);
      for (int i = 1; i < tokens.length; i += 2) {
        String op = tokens[i]!;
        double num = double.parse(tokens[i + 1]!);
        if (op == '+') total += num;
        if (op == '-') total -= num;
        if (op == '*') total *= num;
        if (op == '/') total /= num;
      }
      if (total % 1 == 0) {
        return total.toInt().toString();
      } else {
        return total.toString();
      }
    } catch (e) {
      return '오류';
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonLabels = [
      ['C', '÷', '%', '⌫'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '', '', '='],
    ];
    final media = MediaQuery.of(context);
    final isPortrait = media.orientation == Orientation.portrait;
    final orange = const Color(0xFFFFA726);
    final orangeDark = const Color(0xFFF57C00);

    void showHistoryModal() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      '최근 계산 이력',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _history.isEmpty
                          ? const Center(
                              child: Text(
                                '이력이 없습니다.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: _history.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _history[index],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return Stack(
      children: [
        // 오렌지 그라데이션 배경 (상단 전체)
        Container(
          height: 260,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.white),
                        onPressed: showHistoryModal,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _expression,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _result,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: List.generate(5, (row) {
                    return Expanded(
                      child: Row(
                        children: List.generate(4, (col) {
                          final label = buttonLabels[row][col];
                          if (label.isEmpty) return const Expanded(child: SizedBox.shrink());
                          Color? bgColor = Colors.white;
                          Color? fgColor = Colors.black87;
                          if (label == 'C') {
                            bgColor = Colors.orange.shade100;
                            fgColor = orangeDark;
                          } else if ('÷×-+%'.contains(label)) {
                            bgColor = orange;
                            fgColor = Colors.white;
                          } else if (label == '=') {
                            bgColor = orangeDark;
                            fgColor = Colors.white;
                          } else if (label == '⌫') {
                            bgColor = Colors.orange.shade200;
                            fgColor = orangeDark;
                          }
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: bgColor,
                                    foregroundColor: fgColor,
                                    elevation: 1.5,
                                    shadowColor: Colors.black12,
                                    textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.all(0),
                                  ),
                                  onPressed: () => _onPressed(label),
                                  child: Center(child: Text(label)),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 