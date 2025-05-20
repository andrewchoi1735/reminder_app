import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';
  final List<String> _history = [];

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
        _calculate();
      } else {
        _expression += value;
      }
    });
  }

  void _calculate() {
    try {
      if (_expression.isEmpty) {
        _result = '';
        return;
      }

      final startsWithOp = RegExp(r'^[+\-*/×÷]').hasMatch(_expression);
      final endsWithOp = RegExp(r'[+\-*/×÷]$').hasMatch(_expression);
      if (startsWithOp || endsWithOp) {
        _result = '오류';
        return;
      }

      String exp = _expression.replaceAll('×', '*').replaceAll('÷', '/');
      final tokens = RegExp(r'([\d.]+|[+\-*/])').allMatches(exp).map((e) => e.group(0)!).toList();

      double total = double.parse(tokens[0]!);
      for (int i = 1; i < tokens.length; i += 2) {
        String op = tokens[i]!;
        double num = double.parse(tokens[i + 1]!);
        switch (op) {
          case '+': total += num; break;
          case '-': total -= num; break;
          case '*': total *= num; break;
          case '/': total /= num; break;
        }
      }

      _result = total.toString();
      _history.insert(0, '$_expression = $_result');
    } catch (e) {
      _result = '오류';
    }
  }


  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: _history.isEmpty
              ? const Center(child: Text('계산 이력이 없습니다.'))
              : ListView.separated(
            itemCount: _history.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: Text('#${index + 1}'),
                title: Text(_history[index]),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const buttons = [
      ['C', '⌫', '÷', '×'],
      ['7', '8', '9', '-'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', '='],
      ['0', '.', '', ''],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.calculate),
            SizedBox(width: 8),
            Text('계산기'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistoryModal,
          )
        ],
      ),
      body: Column(
        children: [
          Flexible(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _expression,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            flex: 7,
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.35,
              padding: const EdgeInsets.all(8),
              physics: const NeverScrollableScrollPhysics(),
              children: buttons.expand((row) => row).map((label) {
                return Padding(
                  padding: const EdgeInsets.all(6),
                  child: ElevatedButton(
                    onPressed: label.isNotEmpty ? () => _onPressed(label) : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontSize: 24),
                    ),
                    child: Text(label),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
