import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../providers/ledger_provider.dart';
import 'add_transaction_screen.dart';
import 'package:intl/intl.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  bool _isInitialized = false;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      Provider.of<LedgerProvider>(context, listen: false).setUser(userId);
      _isInitialized = true;
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.book),
            SizedBox(width: 8),
            Text('가계부'),
          ],
        ),
      ),
      body: Consumer<LedgerProvider>(
        builder: (context, ledger, _) {
          final txs = ledger.transactions.where((tx) =>
          tx.date.year == _selectedMonth.year &&
              tx.date.month == _selectedMonth.month).toList();

          final incomeTotal = txs.where((tx) => tx.type == 'income').fold(0, (sum, tx) => sum + tx.amount);
          final expenseTotal = txs.where((tx) => tx.type == 'expense').fold(0, (sum, tx) => sum + tx.amount);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      '${_selectedMonth.year}년 ${_selectedMonth.month}월',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('수입'),
                        Text('${formatter.format(incomeTotal)}원',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('지출'),
                        Text('${formatter.format(expenseTotal)}원',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: txs.isEmpty
                    ? const Center(child: Text('기록된 내역이 없습니다.'))
                    : ListView.separated(
                  itemCount: txs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isIncome = tx.type == 'income';
                    final sign = isIncome ? '+' : '-';
                    final color = isIncome ? Colors.green : Colors.red;

                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        Provider.of<LedgerProvider>(context, listen: false).deleteTransaction(tx.id!);
                      },
                      child: ListTile(
                        title: Text(tx.title),
                        subtitle: Text(tx.date.toString().split(' ').first),
                        trailing: Text(
                          '$sign${formatter.format(tx.amount)}원',
                          style: TextStyle(color: color),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddTransactionScreen(existingTransaction: tx),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
